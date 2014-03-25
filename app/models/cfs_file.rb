require 'rest_client'

class CfsFile < ActiveRecord::Base
  belongs_to :cfs_directory

  has_many :red_flags, :as => :red_flaggable, :dependent => :destroy

  validates_uniqueness_of :name, scope: :cfs_directory_id, allow_blank: false

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

  def run_initial_assessment
    file_info = File.stat(self.absolute_path)
    self.size = file_info.size
    self.mtime = file_info.mtime
    self.content_type = (FileMagic.new(FileMagic::MAGIC_MIME_TYPE).file(self.absolute_path) rescue 'application/octet-stream')
    self.md5_sum = Digest::MD5.file(self.absolute_path).to_s
    self.save!
  end

  def ensure_fits_xml
    if self.fits_xml.blank?
      self.fits_xml = self.get_fits_xml
      self.save!
    end
  end

  protected

  def get_fits_xml
    file_path = self.absolute_path.gsub(/^\/+/, '')
    resource = RestClient::Resource.new("http://localhost:4567/fits/file/#{file_path}")
    response = resource.get
    response.body
  end

end