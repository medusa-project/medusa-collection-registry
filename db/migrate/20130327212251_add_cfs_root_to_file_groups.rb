class AddCfsRootToFileGroups < ActiveRecord::Migration
  def change
    add_column :file_groups, :cfs_root, :string
    add_index :file_groups, :cfs_root, unique: true
  end
end
