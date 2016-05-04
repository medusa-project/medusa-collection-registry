require 'rest_client'
require 'digest/md5'
require 'set'

class CfsFile < ActiveRecord::Base

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

  delegate :repository, :collection, :file_group, :public?, to: :cfs_directory
  delegate :name, to: :content_type, prefix: true, allow_nil: true
  FitsData::ALL_FIELDS.each do |field|
    delegate field, to: :fits_data, prefix: true, allow_nil: true
  end

  validates_uniqueness_of :name, scope: :cfs_directory_id, allow_blank: false

  #last fixity check was ok, not ok, or the file was not found. Nil value indicates
  #that no fixity check (after possibly the initial generation of the checksum) has been run -
  #this may be the case while bootstrapping this.
  FIXITY_STATUSES = %w(ok bad nf)
  validates_inclusion_of :fixity_check_status, in: FIXITY_STATUSES, allow_nil: true

  before_validation :ensure_current_file_extension
  after_save :ensure_fits_xml_for_large_file

  breadcrumbs parent: :cfs_directory, label: :name
  cascades_events parent: :cfs_directory
  cascades_red_flags parent: :cfs_directory

  searchable include: {cfs_directory: {root_cfs_directory: {parent_file_group: :collection}}} do
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
  end

  def self.with_fits
    where(fits_serialized: true)
  end

  def relative_path
    File.join(self.cfs_directory.relative_path, self.name)
  end

  def absolute_path
    File.join(CfsRoot.instance.path, self.relative_path)
  end

  def exists_on_filesystem?
    File.exists?(self.absolute_path)
  end

  #the directories leading up to the file
  def ancestors
    self.cfs_directory.ancestors_and_self
  end

  #run an initial assessment on files that need it - skip if we've already done it and the mtime hasn't changed
  def run_initial_assessment
    file_info = File.stat(self.absolute_path)
    #This won't guarantee that we rerun if the file has changed, but it should pick up most of the cases. mtime only seems to go
    #down to the second
    if self.mtime.blank? or (file_info.mtime > self.mtime) or (file_info.size != self.size)
      self.size = file_info.size
      self.mtime = file_info.mtime
      self.content_type_name = (FileMagic.new(FileMagic::MAGIC_MIME_TYPE).file(self.absolute_path) rescue 'application/octet-stream')
      self.set_fixity(self.file_system_md5_sum)
      self.save!
    end
  end

  #Does not save, only sets in memory
  def set_fixity(md5sum)
    if self.md5_sum.present?
      if self.md5_sum == md5sum
        set_fixity_status_ok
      else
        set_fixity_status_bad
      end
    else
      self.md5_sum = md5sum
      set_fixity_status_ok
    end
  end

  def set_fixity_status_ok
    self.fixity_check_status = 'ok'
    self.fixity_check_time = Time.now
  end

  def set_fixity_status_bad
    self.fixity_check_status = 'bad'
    self.fixity_check_time = Time.now
  end

  def set_fixity_status_not_found
    self.fixity_check_status = 'nf'
    self.fixity_check_time = Time.now
  end

  def update_fixity_status_ok_with_event(actor_email: nil)
    actor_email ||= MedusaBaseMailer.admin_address
    create_fixity_event(cascadable: false, note: 'OK', actor_email: actor_email)
    set_fixity_status_ok
    save!
  end

  def update_fixity_status_bad_with_event(actor_email: nil)
    actor_email ||= MedusaBaseMailer.admin_address
    create_fixity_event(cascadable: true, note: 'FAILED', actor_email: actor_email)
    red_flags.create!(message: "Md5 Sum changed. Recorded: #{md5_sum} Current: #{file_system_md5_sum}. Cfs File Id: #{self.id}")
    set_fixity_status_bad
    save!
  end

  def update_fixity_status_not_found_with_event(actor_email: nil)
    actor_email ||= MedusaBaseMailer.admin_address
    create_fixity_event(cascadable: true, note: 'NOT_FOUND', actor_email: actor_email)
    red_flags.create!(message: "File not found for fixity check. Cfs File Id: #{self.id}")
    set_fixity_status_not_found
    save!
  end

  def create_fixity_event(params = {})
    params.merge!(key: 'fixity_result', date: Date.today)
    events.create!(params)
  end

  def ensure_fits_xml
    self.update_fits_xml unless fits_serialized
  end

  def ensure_fits_xml_for_large_file
    self.delay(priority: 70).ensure_fits_xml if !fits_serialized? and self.size.present? and self.size > 5.gigabytes
  end

  def update_fits_xml
    self.fits_xml = self.get_fits_xml
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

  def update_content_type_from_fits(new_content_type_name)
    #don't update something to a less specific content type
    return if new_content_type_name == 'application/octet-stream' and self.content_type_name.present?
    if self.content_type_name != new_content_type_name
      #For this one we don't report a red flag if this is the first generation of
      #the fits xml overwriting the content type found by the 'file' command
      unless self.content_type.blank? or self.fits_result.new?
        self.red_flags.create(message: "Content Type changed. Old: #{self.content_type_name} New: #{new_content_type_name}")
      end
      self.content_type_name = new_content_type_name
    end
  end

  def content_type_name=(name)
    if name.present?
      self.content_type = ContentType.find_or_create_by(name: name)
    else
      self.content_type = nil
    end
  end

  def file_system_md5_sum
    Digest::MD5.file(self.absolute_path).hexdigest
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

  def fits_result
    @fits_result ||= FitsResult.new(self)
  end

  protected

  def get_fits_xml
    uri = URI(File.join(Application.medusa_config.fits_server_url, 'fits/file'))
    uri.query = URI.encode_www_form({path: self.absolute_path.gsub(/^\/+/, '')})
    response = HTTParty.get(uri.to_s, timeout: 3000)
    case response.code
      when 200
        response.body
      when 404
        raise RuntimeError, "File not found for FITS: #{self.absolute_path}"
      else
        raise RuntimeError, "Bad response from FITS server: Code #{response.code}. Body: #{response.body}"
    end
  end

  def safe_size
    self.size || 0
  end

  def safe_size_was
    self.size_was || 0
  end

  def self.random
    self.offset(rand(self.count)).first
  end

end