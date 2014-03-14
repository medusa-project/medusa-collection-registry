class ExternalFileGroup < FileGroup

  before_save :nullify_cfs_directory

  def storage_level
    'external'
  end

  def self.downstream_types
    ['BitLevelFileGroup', 'ObjectLevelFileGroup']
  end

end