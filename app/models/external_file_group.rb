class ExternalFileGroup < FileGroup

  before_save :nullify_cfs_directory

  def storage_level
    'external'
  end

  def self.downstream_types
    ['BitLevelFileGroup', 'ObjectLevelFileGroup']
  end

  def has_staged_directory?
    #check that the staged_file_location is okay - it must end in collection_id/file_group_id
    #check that the staged storage has a matching root
    #check that the corresponding staged storage local directory exists
  end

  def ready_for_bit_level_ingest?
    self.has_staged_directory?
  end

end