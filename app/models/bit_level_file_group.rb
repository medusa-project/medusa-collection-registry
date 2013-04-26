class BitLevelFileGroup < FileGroup
  after_save :schedule_create_cfs_file_infos

  def storage_level
    'bit-level store'
  end
end