class ExternalFileGroup < FileGroup

  validates_absence_of :cfs_directory

  def storage_level
    'external'
  end

  def self.downstream_types
    %w(BitLevelFileGroup)
  end

  def lacks_related_bit_level_file_group?
    self.target_file_groups.blank?
  end

  def create_related_bit_level_file_group
    BitLevelFileGroup.new(self.attributes.slice('producer_id', 'title', 'collection_id')).tap do |bit_level_file_group|
      bit_level_file_group.save!
      self.target_file_group_joins.create(target_file_group_id: bit_level_file_group.id, note: 'Created by automatic ingest')
    end
  end
end

