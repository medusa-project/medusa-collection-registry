class RemoveRootDirectoryIdFromFileGroups < ActiveRecord::Migration
  def up
    remove_column :file_groups, :root_directory_id
  end

  def down
    add_column :file_groups, :root_directory_id, :int
    add_index :file_groups, :root_directory_id, :unique => true
  end
end
