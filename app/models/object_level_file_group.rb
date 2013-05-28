class ObjectLevelFileGroup < FileGroup

  def storage_level
    'object-level store'
  end

  def self.downstream_types
    []
  end

end