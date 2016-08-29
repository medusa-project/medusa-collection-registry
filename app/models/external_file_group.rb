class ExternalFileGroup < FileGroup

  validates_absence_of :cfs_directory

  def storage_level
    'external'
  end

  def self.downstream_types
    %w(BitLevelFileGroup ObjectLevelFileGroup)
  end

  #check that the staged_file_location is okay - it must end in collection_id/file_group_id
  #check that the staged storage has a matching root
  #check that the corresponding staged storage local directory exists
  def has_staged_directory?
    self.staged_file_location and
        StagingStorage.normalize_path(self.staged_file_location).match(/#{self.collection_id}\/#{self.id}$/) and
        self.local_staged_file_location
  end

  def local_staged_file_location
    StagingStorage.instance.local_path_for(self.staged_file_location)
  end

  def ready_for_bit_level_ingest?
    self.has_staged_directory? and
        !self.target_file_groups.present?
  end

  def lacks_related_bit_level_file_group?
    self.target_file_groups.blank?
  end

  def create_related_bit_level_file_group
    BitLevelFileGroup.new(self.attributes.slice('producer_id', 'package_profile_id',
                                                'title', 'collection_id')).tap do |bit_level_file_group|
      bit_level_file_group.save!
      self.target_file_group_joins.create(target_file_group_id: bit_level_file_group.id, note: 'Created by automatic ingest')
    end
  end
end

