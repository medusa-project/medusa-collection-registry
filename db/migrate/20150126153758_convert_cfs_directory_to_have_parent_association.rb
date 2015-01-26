class ConvertCfsDirectoryToHaveParentAssociation < ActiveRecord::Migration
  def up
    add_column :cfs_directories, :parent_id, :integer, index: true
    add_column :cfs_directories, :parent_type, :string
    ActiveRecord::Base.connection.execute("UPDATE cfs_directories SET parent_id=parent_cfs_directory_id, parent_type='CfsDirectory' where parent_cfs_directory_id IS NOT NULL")
    ActiveRecord::Base.connection.execute("UPDATE cfs_directories SET parent_id=file_group_id, parent_type='BitLevelFileGroup' where file_group_id IS NOT NULL")
    add_index :cfs_directories, [:parent_type, :parent_id, :path], unique: true, name: :cfs_directory_parent_idx
    remove_column :cfs_directories, :file_group_id
    remove_column :cfs_directories, :parent_cfs_directory_id
  end

  def down
    add_column :cfs_directories, :parent_cfs_directory_id, :integer, index: true
    add_column :cfs_directories, :file_group_id, :integer, index: true
    ActiveRecord::Base.connection.execute("UPDATE cfs_directories SET file_group_id=parent_id WHERE parent_type='BitLevelFileGroup'")
    ActiveRecord::Base.connection.execute("Update cfs_directories SET parent_cfs_directory_id=parent_id WHERE parent_type='CfsDirectory'")
    remove_index :cfs_directories, name: :cfs_directory_parent_idx
    remove_column :cfs_directories, :parent_type
    remove_column :cfs_directories, :parent_id
  end
end
