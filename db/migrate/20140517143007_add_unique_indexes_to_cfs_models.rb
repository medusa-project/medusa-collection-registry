class AddUniqueIndexesToCfsModels < ActiveRecord::Migration
  def change
    remove_index :cfs_files, :cfs_directory_id
    remove_index :cfs_directories, :parent_cfs_directory_id
    add_index :cfs_files, [:cfs_directory_id, :name], :unique => true
    add_index :cfs_directories, [:parent_cfs_directory_id, :path], :unique => true
  end
end
