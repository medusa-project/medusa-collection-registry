require 'digest/md5'
require 'set'

class CfsFile < ApplicationRecord

  include Eventable
  include CascadedEventable
  include CascadedRedFlaggable
  include Uuidable
  include Breadcrumb
  include CfsFileAmqp

  belongs_to :cfs_directory
  belongs_to :content_type
  belongs_to :file_extension
  belongs_to :parent, class_name: 'CfsDirectory', foreign_key: 'cfs_directory_id'
  has_one :file_format_test, dependent: :destroy
  has_one :fits_data, dependent: :destroy, autosave: true

  has_many :red_flags, as: :red_flaggable, dependent: :destroy
  has_many :fixity_check_results, -> {order 'created_at DESC'}, dependent: :destroy

  delegate :repository, :collection, :file_group, :root_cfs_directory, to: :cfs_directory
  delegate :name, to: :content_type, prefix: true, allow_nil: true
  FitsData::all_fields.each do |field|
    delegate field, to: :fits_data, prefix: true, allow_nil: true
  end

  validates_uniqueness_of :name, scope: :cfs_directory_id, allow_blank: false
  validates_format_of :name, without: /\//

  #last fixity check was ok, not ok, or the file was not found. Nil value indicates
  #that no fixity check (after possibly the initial generation of the checksum) has been run -
  #this may be the case while bootstrapping this.
  FIXITY_STATUSES = %w(ok bad nf)
  validates_inclusion_of :fixity_check_status, in: FIXITY_STATUSES, allow_nil: true

  before_validation :ensure_current_file_extension
  #after_save :ensure_fits_xml_for_large_file
  before_destroy :remove_fits_xml_on_destroy

  breadcrumbs parent: :cfs_directory, label: :name
  cascades_events parent: :cfs_directory
  cascades_red_flags parent: :cfs_directory

  searchable include: {cfs_directory: {root_cfs_directory: {parent_file_group: :collection}}} do
    integer :model_id, using: :id
    text :name
    string :name, stored: true
    string :path do
      cfs_directory.path
    end
    string :collection_title do
      collection.try(:title)
    end
    string :file_group_title do
      file_group.try(:title)
    end
    time :mtime
    double :size
    integer :cfs_directory_id
  end

  def self.with_fits
    where(fits_serialized: true)
  end

  def self.without_fits
    where(fits_serialized: false)
  end

  def self.bad_fixity
    where(fixity_check_status: 'bad')
  end

  def self.not_found_fixity
    where(fixity_check_status: 'nf')
  end

  def relative_path
    File.join(self.cfs_directory.relative_path, self.name)
  end

  def key
    relative_path
  end

  def exists_on_storage?
    storage_root.exist?(self.key)
  end

  def remove_from_storage
    storage_root.delete_content(self.key)
  end

  #wrap the storage root's ability to yield a file path having the appropriate content in it
  def with_input_file
    storage_root.with_input_file(self.key, tmp_dir: tmpdir_for_with_input_file) do |file|
      yield file
    end
  end

  #Set this up so that we use local storage for small files, for some definition of small
  # might want to extract this elsewhere so that is generally available and easy to make
  # robust for whatever application.
  def tmpdir_for_with_input_file
    expected_size = size || storage_root.size(key)
    if expected_size > Settings.classes.cfs_file.tmpdir_cutoff_size
      Application.storage_manager.tmpdir
    else
      Dir.tmpdir
    end
  end

  #wrap the storage root's ability to yield an io on the content
  def with_input_io
    storage_root.with_input_io(self.key) do |io|
      yield io
    end
  end

  def storage_root
    Application.storage_manager.main_root
  end

  #the directories leading up to the file
  def ancestors
    self.cfs_directory.ancestors_and_self
  end

  #run an initial assessment on files that need it - skip if we've already done it and the mtime hasn't changed
  def run_initial_assessment
    external_mtime = storage_root.mtime(self.key)
    external_size = storage_root.size(self.key)
    #This won't guarantee that we rerun if the file has changed, but it should pick up most of the cases. mtime only seems to go
    #down to the second
    if self.mtime.blank? or (external_mtime > self.mtime) or (external_size != self.size)
      self.size = external_size
      self.mtime = external_mtime
      computed_content_type = with_input_file do |input_file|
        (FileMagic.new(FileMagic::MAGIC_MIME_TYPE).file(input_file) rescue 'application/octet-stream')
      end
      self.set_fixity(self.storage_md5_sum)
      transaction do
        self.content_type_name = computed_content_type
        self.save!
      end
    end
  end

  #Does not save, only sets in memory
  def set_fixity(md5sum)
    if self.md5_sum.present?
      if self.md5_sum == md5sum
        set_fixity_status('ok')
      else
        set_fixity_status('bad')
      end
    else
      self.md5_sum = md5sum
      set_fixity_status('ok')
    end
  end

  def set_fixity_status(status)
    self.fixity_check_status = status
    self.fixity_check_time = Time.now
  end

  def update_fixity_status_with_event(md5sum: nil, actor_email: nil)
    update_fixity_status_not_found_with_event(actor_email: actor_email) and return unless exists_on_storage?
    md5sum ||= self.storage_md5_sum
    if self.md5_sum.present?
      if self.md5_sum == md5sum
        update_fixity_status_ok
      else
        update_fixity_status_bad_with_event(actor_email: actor_email)
      end
    else
      update_fixity_status_ok
    end
  end

  def update_fixity_status_ok
    transaction do
      fixity_check_results.create!(status: :ok)
      set_fixity_status('ok')
      save!
    end
  end

  def update_fixity_status_bad_with_event(actor_email: nil)
    actor_email ||= MedusaBaseMailer.admin_address
    transaction do
      fixity_check_results.create!(status: :bad)
      create_fixity_event(cascadable: true, note: 'FAILED', actor_email: actor_email)
      red_flags.create!(message: "Md5 Sum changed. Recorded: #{md5_sum} Current: #{storage_md5_sum}. Cfs File Id: #{self.id}")
      set_fixity_status('bad')
      save!
    end
  end

  def update_fixity_status_not_found_with_event(actor_email: nil)
    actor_email ||= MedusaBaseMailer.admin_address
    transaction do
      fixity_check_results.create!(status: :not_found)
      create_fixity_event(cascadable: true, note: 'NOT_FOUND', actor_email: actor_email)
      red_flags.create!(message: "File not found for fixity check. Cfs File Id: #{self.id}")
      set_fixity_status('nf')
      save!
    end
  end

  def create_fixity_event(params = {})
    params.merge!(key: 'fixity_result', date: Date.today)
    events.create!(params)
  end

  def ensure_fits_xml
    self.update_fits_xml unless fits_serialized
  end

  def ensure_fits_xml_for_large_file
    self.delay(priority: Settings.delayed_job.priority.large_file_fits).ensure_fits_xml if
        !fits_serialized? and self.size.present? and self.size > Settings.classes.cfs_file.large_file_fits_cutoff_size
  end

  def update_fits_xml(xml: nil)
    xml ||= get_fits_xml
    self.fits_xml = xml
    self.update_fields_from_fits
    self.save!
  end

  def update_fields_from_fits
    doc = Nokogiri::XML::Document.parse(self.fits_xml)
    update_size_from_fits(doc.at_css('fits fileinfo size').text.to_d)
    update_md5_sum_from_fits(doc.at_css('fits fileinfo md5checksum').text)
    update_content_type_from_fits(doc.at_css('fits identification identity')['mimetype'])
  rescue Exception
    Rails.logger.error("*********** Couldn't update cfs file #{self.id} from FITS: #{self.fits_xml}")
    raise
  end

  def update_size_from_fits(new_size)
    if size != new_size
      self.red_flags.create(message: "Size changed. Old: #{self.size} New: #{new_size}") unless self.size.blank?
      self.size = new_size
    end
  end

  def update_md5_sum_from_fits(new_md5_sum)
    if self.md5_sum != new_md5_sum
      self.red_flags.create(message: "Md5 Sum changed. Old: #{self}.md5_sum} New: #{new_md5_sum}}") unless self.md5_sum.blank?
      self.md5_sum = new_md5_sum
    end
  end

  #TODO this and the method it calls are ripe for cleaning up and possibly setting through configuration
  def update_content_type_from_fits(new_content_type_name)
    #don't update something to a less specific content type
    return if new_content_type_name == 'application/octet-stream' and content_type_name.present?
    return if new_content_type_name == 'text/plain' and content_type_name.present? and content_type_name.start_with?('text/')
    if content_type_name != new_content_type_name
      #For this one we don't report a red flag if this is the first generation of
      #the fits xml overwriting the content type found by the 'file' command
      if content_type.present? and !fits_result.new? and !expected_content_type_change?(content_type_name, new_content_type_name)
        self.red_flags.create(message: "Content Type changed. Old: #{content_type_name} New: #{new_content_type_name}")
      end
      self.content_type_name = new_content_type_name
    end
  end

  def expected_content_type_change?(old_name, new_name)
    return true if old_name == 'application/octet-stream'
    return true if old_name == 'application/ogg' and new_name == 'audio/ogg'
    return true if old_name == 'application/vnd.ms-office' and new_name.start_with?('application/vnd.ms-')
    return true if old_name == 'application/xml' and new_name == 'text/xml'
    return true if old_name == 'text/html' and new_name == 'text/xml'
    return true if old_name == 'text/plain' and new_name.start_with?('text/')
    return true if old_name == 'video/x-msvideo' and new_name == 'video/avi'
    return true if new_name.match(old_name)
    return false
  end

  def content_type_name=(name)
    if name.present?
      self.content_type = ContentType.find_or_create_by(name: name)
    else
      self.content_type = nil
    end
  end

  def storage_md5_sum
    storage_root.hex_md5_sum(self.key)
  end

  def ensure_current_file_extension
    self.file_extension = FileExtension.ensure_for_name(self.name)
  end

  def self.ensure_all_file_extensions
    count = CfsFile.where('file_extension_id is null').count
    CfsFile.where('file_extension_id is null').find_each.with_index do |cfs_file, i|
      if (i + 1) % 5000 == 0
        puts "Ensuring file extension for #{i + 1} of #{count}"
      end
      cfs_file.ensure_current_file_extension
      cfs_file.save!
    end
  end

  def random_file_format_profile
    file_extension_profiles = self.file_extension.file_format_profiles.active.to_set
    content_type_profiles = self.content_type.file_format_profiles.active.to_set
    file_extension_profiles.intersection(content_type_profiles).to_a.sample ||
        file_extension_profiles.union(content_type_profiles).to_a.sample
  end

  def ensure_fits_data
    self.fits_data ||= build_fits_data
    self.fits_data.update_from(self.fits_xml) if self.fits_xml.present?
  end

  def fits_xml
    self.fits_result.xml
  end

  def fits_xml=(value)
    fits_result.xml = value
    ensure_fits_data
  end

  def remove_fits
    self.fits_data.destroy! if self.fits_data.present?
    self.fits_result.remove_serialized_xml
    self.reload
  end

  def remove_fits_xml_on_destroy
    self.fits_result.remove_serialized_xml(update_cfs_file: false) rescue nil
  end

  def fits_result
    @fits_result ||= FitsResult.new(self)
  end

  def previewer
    Preview::Resolver.instance.find_previewer(self)
  end

  def previewer_type
    Preview::Resolver.instance.find_preview_viewer_type(self)
  end

  def preview_type_is_image?
    previewer_type == :image
  end

  def reset_fixity_and_fits!(actor_email: nil)
    actor_email ||= Settings.medusa.email.admin
    transaction do
      self.md5_sum = nil
      self.size = nil
      self.mtime = nil
      self.content_type = nil
      self.fixity_check_time = nil
      self.fixity_check_status = nil
      self.fits_data.try(:destroy!)
      self.events.create(key: :fixity_reset, note: 'Overwriting accrual', cascadable: false, actor_email: actor_email)
      #we do this one last because it has an effect outside the database, viz. removing the fits file
      self.fits_result.remove_serialized_xml
      save!
    end
  end

  def create_amqp_accrual_event(actor_email: nil)
    actor_email ||= Settings.medusa.email.admin
    events.create(key: :amqp_accrual, note: 'Initial accrual', cascadable: true, actor_email: actor_email)
  end

  def after_restore
    Sunspot.index self
    events.find_each do |event|
      event.recascade
    end
  end

  #Get any other cfs files with the same md5_sum. Useful for debugging certain things like moves, etc.
  def md5_duplicates
    CfsFile.where(md5_sum: md5_sum).where('id != ?', id).to_a
  end

  protected

  def get_fits_xml
    with_input_file do |input_file|
      uri = URI(File.join(Settings.fits.server_url, 'fits/file'))
      uri.query = URI.encode_www_form({path: input_file.gsub(/^\/+/, '')})
      response = HTTParty.get(uri.to_s, timeout: 3600 * 12)
      case response.code
      when 200
        response.body
      when 404
        raise RuntimeError, "File not found for FITS: #{self.input_file}"
      else
        raise RuntimeError, "Bad response from FITS server: Code #{response.code}. Body: #{response.body}"
      end
    end
  end

  def safe_size
    self.size || 0
  end

  def safe_size_was
    self.size_was || 0
  end

  def self.random
    self.offset(rand(self.fast_count)).first
  end

  def self.fast_count
    BitLevelFileGroup.sum(:total_files)
  end

end
