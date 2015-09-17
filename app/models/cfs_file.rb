require 'rest_client'
require 'digest/md5'

class CfsFile < ActiveRecord::Base
  include Eventable
  include CascadedEventable
  include Uuidable
  include Breadcrumb
  include CfsFileAmqp

  belongs_to :cfs_directory, touch: true
  belongs_to :content_type, touch: true
  belongs_to :file_extension, touch: true
  belongs_to :parent, class_name: 'CfsDirectory', foreign_key: 'cfs_directory_id'

  has_many :red_flags, as: :red_flaggable, dependent: :destroy

  delegate :repository, :file_group, :public?, to: :cfs_directory
  delegate :name, to: :content_type, prefix: true, allow_nil: true

  validates_uniqueness_of :name, scope: :cfs_directory_id, allow_blank: false

  #last fixity check was ok, not ok, or the file was not found. Nil value indicates
  #that no fixity check (after possibly the initial generation of the checksum) has been run -
  #this may be the case while bootstrapping this.
  FIXITY_STATUSES = %w(ok bad nf)
  validates_inclusion_of :fixity_check_status, in: FIXITY_STATUSES, allow_nil: true

  after_create :add_content_type_stats
  after_destroy :remove_content_type_stats
  after_update :update_content_type_stats

  before_validation :ensure_current_file_extension
  after_create :add_file_extension_stats
  after_destroy :remove_file_extension_stats
  after_update :update_file_extension_stats

  breadcrumbs parent: :cfs_directory, label: :name
  cascades_events parent: :cfs_directory

  searchable do
    text :name
    string :name, stored: true
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
    self.update_fits_xml if self.fits_xml.blank?
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
      unless self.content_type.blank? or self.fits_xml_was.blank?
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

  protected

  def add_content_type_stats
    self.content_type.update_stats(1, self.safe_size) if self.content_type.present?
  end

  def update_content_type_stats
    if self.content_type_id_changed?
      if self.content_type.present?
        self.content_type.update_stats(1, self.safe_size)
      end
      if self.content_type_id_was.present?
        ContentType.find(self.content_type_id_was).update_stats(-1, -1 * self.safe_size_was)
      end
    else
      if self.content_type.present? and self.size_changed?
        self.content_type.update_stats(0, (self.safe_size - self.safe_size_was))
      end
    end
  end

  def remove_content_type_stats
    self.content_type.update_stats(-1, -1 * self.safe_size) if self.content_type.present?
  end

  def add_file_extension_stats
    self.file_extension.update_stats(1, self.safe_size)
    true
  end

  def update_file_extension_stats
    if self.file_extension_id_changed?
      self.file_extension.update_stats(1, self.safe_size)
      FileExtension.find(self.file_extension_id_was).update_stats(-1, -1 * self.safe_size_was) if self.file_extension_id_was
    else
      if self.size_changed?
        self.file_extension.update_stats(0, self.safe_size - self.safe_size_was)
      end
    end
  end

  def remove_file_extension_stats
    self.file_extension.update_stats(-1, -1 * self.safe_size)
  end

  def get_fits_xml
    resource = RestClient::Resource.new("http://localhost:4567/fits/file")
    response = resource.get(params: {path: self.absolute_path.gsub(/^\/+/, '')})
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

end