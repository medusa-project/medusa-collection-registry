class AddCfsDirectoryToFileGroups < ActiveRecord::Migration
  def change
    add_column :file_groups, :cfs_directory_id, :integer
    add_index :file_groups, :cfs_directory_id
  end
end
