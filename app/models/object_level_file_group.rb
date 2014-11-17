class ObjectLevelFileGroup < FileGroup

  validates_absence_of :cfs_directory

  def storage_level
    'object-level store'
  end

  def self.downstream_types
    []
  end

end