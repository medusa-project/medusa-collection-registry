require 'fileutils'

class FitsResult < ActiveRecord::Base
  belongs_to :cfs_file

  before_save :serialize_xml
  before_destroy :remove_serialized_xml

  def self.storage_root
    Application.medusa_config.fits_storage
  end

  def self.serialize_all
    self.find_each do |fits_result|
      fits_result.serialize_xml unless fits_result.serialized?
    end
  end
  
  def storage_directory
    File.join(self.class.storage_root, cfs_file_uuid.first(6).chars.in_groups_of(2).collect(&:join))
  end

  def storage_file
    File.join(storage_directory, "#{self.cfs_file_uuid}.xml")
  end

  def cfs_file_uuid
    self.cfs_file.uuid
  end

  def serialized?
    File.exists?(self.storage_file)
  end

  def serialize_xml
    FileUtils.mkdir_p(storage_directory)
    File.open(storage_file, 'w') do |f|
      f.write(self.xml)
    end
  end

  def remove_serialized_xml
    File.delete(storage_file) if File.exist?(storage_file)
  end

end