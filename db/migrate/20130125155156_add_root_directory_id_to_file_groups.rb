class AddRootDirectoryIdToFileGroups < ActiveRecord::Migration
  def change
    add_column :file_groups, :root_directory_id, :int
    add_index :file_groups, :root_directory_id, :unique => true
  end
end
