class AddRootDirectoryIdToCfsDirectories < ActiveRecord::Migration
  def change
    add_column :cfs_directories, :root_cfs_directory_id, :integer
    add_index :cfs_directories, :root_cfs_directory_id
  end
end
