class ExternalFileGroup < FileGroup

  def storage_level
    'external'
  end

  def self.downstream_types
    ['BitLevelFileGroup', 'ObjectLevelFileGroup']
  end

end