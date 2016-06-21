require 'fileutils'

class FitsResult < Object
  attr_accessor :cfs_file, :new

  def initialize(cfs_file)
    self.cfs_file = cfs_file
    self.new = !self.serialized?
  end

  def self.storage_root
    Application.medusa_config.fits_storage
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

  def present?
    serialized?
  end

  def serialize_xml
    FileUtils.mkdir_p(storage_directory)
    File.open(storage_file, 'w') do |f|
      f.write(self.xml)
    end
    cfs_file.with_lock do
      cfs_file.fits_serialized = true
      cfs_file.save!
    end
  end

  def remove_serialized_xml(update_cfs_file: true)
    File.delete(storage_file) if File.exist?(storage_file)
    self.cfs_file.update_attribute(:fits_serialized, false) if update_cfs_file
  end

  def xml
    serialized? ? File.read(storage_file) : nil
  end

  def xml=(string)
    FileUtils.mkdir_p(storage_directory)
    File.open(storage_file, 'w') do |f|
      f.write(string)
    end
    self.cfs_file.update_attribute(:fits_serialized, true)
  end

  def new?
    self.new
  end

end