require 'rest_client'

class CfsFile < ActiveRecord::Base
  belongs_to :cfs_directory

  has_many :red_flags, :as => :red_flaggable, :dependent => :destroy

  validates_uniqueness_of :name, scope: :cfs_directory_id, allow_blank: false

  after_save :update_cfs_directory_tree_size_and_count
  after_destroy :update_cfs_directory_tree_size_and_count

  def repository
    self.cfs_directory.repository
  end

  def label
    self.relative_path
  end

  def cfs_label
    self.relative_path
  end

  def relative_path
    File.join(self.cfs_directory.relative_path, self.name)
  end

  def absolute_path
    File.join(CfsRoot.instance.path, self.relative_path)
  end

  def file_group
    self.cfs_directory.owning_file_group
  end

  def self.cfs_type
    'CFS File'
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
      self.content_type = (FileMagic.new(FileMagic::MAGIC_MIME_TYPE).file(self.absolute_path) rescue 'application/octet-stream')
      self.md5_sum = Digest::MD5.file(self.absolute_path).to_s
      self.save!
    end
  end

  def ensure_fits_xml
    if self.fits_xml.blank?
      self.update_fits_xml
    end
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
  end

  def update_size_from_fits(new_size)
    if size != new_size
      self.red_flags.create(:message => "Size changed. Old: #{self.size} New: #{new_size}") unless self.size.blank?
      self.size = new_size
    end
  end

  def update_md5_sum_from_fits(new_md5_sum)
    if self.md5_sum != new_md5_sum
      self.red_flags.create(:message => "Md5 Sum changed. Old: #{self}.md5_sum} New: #{new_md5_sum}}") unless self.md5_sum.blank?
      self.md5_sum = new_md5_sum
    end

    def update_content_type_from_fits(new_content_type)
      if self.content_type != new_content_type
        #For this one we don't report a red flag if this is the first generation of
        #the fits xml overwriting the content type found by the 'file' command
        unless self.content_type.blank? or self.fits_xml_was.blank?
          self.red_flags.create(:message => "Content Type changed. Old: #{self.content_type} New: #{new_content_type}")
        end
      end
      self.content_type = new_content_type
    end
  end

  def public?
    self.cfs_directory.public?
  end

  protected

  def update_cfs_directory_tree_size_and_count
    self.cfs_directory.update_tree_size_and_count
  end

  def get_fits_xml
    file_path = URI.encode(self.absolute_path.gsub(/^\/+/, ''))
    resource = RestClient::Resource.new("http://localhost:4567/fits/file/#{file_path}")
    response = resource.get
    response.body
  end

end