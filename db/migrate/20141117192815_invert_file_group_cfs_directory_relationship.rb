#we want to make the cfs directories belong to BitLevelFileGroups instead of the reverse, so we need to
#add/subtract the appropriate fields and move the data correctly. Moreover, we want to do this so that
#we don't actually use the relationships, as they will be affected near this migration.
class InvertFileGroupCfsDirectoryRelationship < ActiveRecord::Migration

  def up
    add_column :cfs_directories, :file_group_id, :integer, unique: true
    FileGroup.all.each do |file_group|
      if file_group.cfs_directory_id
        cfs_directory = CfsDirectory.find(file_group.cfs_directory_id)
        cfs_directory.file_group_id = file_group.id
        cfs_directory.save!
      end
    end
    remove_column :file_groups, :cfs_directory_id
  end

  def down
    add_column :file_groups, :cfs_directory_id, :integer, unique: true
    CfsDirectory.all.each do |cfs_directory|
      if cfs_directory.file_group_id
        file_group = FileGroup.find(cfs_directory.file_group_id)
        file_group.cfs_directory_id = cfs_directory.id
        file_group.save!
      end
    end
    remove_column :cfs_directories, :file_group_id
  end
end
