class AddTreeSizeToCfsDirectories < ActiveRecord::Migration
  def change
    add_column :cfs_directories, :tree_size, :decimal, default: 0
  end
end
