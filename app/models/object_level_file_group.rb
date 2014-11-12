class ObjectLevelFileGroup < FileGroup

  before_save :nullify_cfs_directory
  validates_absence_of :cfs_directory

  def storage_level
    'object-level store'
  end

  def self.downstream_types
    []
  end

end