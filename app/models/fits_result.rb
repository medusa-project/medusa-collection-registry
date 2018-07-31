class FitsResult < Object
  attr_accessor :cfs_file, :new
  delegate :storage_root, to: :class

  def initialize(cfs_file)
    self.cfs_file = cfs_file
    self.new = !self.serialized?
  end

  def self.storage_root
    Application.storage_manager.fits_root
  end

  def storage_key
    File.join(cfs_file_uuid.first(6).chars.in_groups_of(2).collect(&:join), "#{self.cfs_file_uuid}.xml")
  end

  def cfs_file_uuid
    self.cfs_file.uuid
  end

  def serialized?
    storage_root.exist?(storage_key)
  end

  def present?
    serialized?
  end

  def serialize_xml
    storage_root.write_string_to(storage_key, self.xml)
    cfs_file.with_lock do
      cfs_file.fits_serialized = true
      cfs_file.save!
    end
  end

  def remove_serialized_xml(update_cfs_file: true)
    storage_root.delete_content(storage_key) if serialized?
    self.cfs_file.update_attribute(:fits_serialized, false) if update_cfs_file
  end

  def xml
    serialized? ? storage_root.as_string(storage_key) : nil
  end

  def xml=(string)
    storage_root.write_string_to(storage_key, string)
    self.cfs_file.update_attribute(:fits_serialized, true) unless self.cfs_file.fits_serialized
  end

  def new?
    self.new
  end

end