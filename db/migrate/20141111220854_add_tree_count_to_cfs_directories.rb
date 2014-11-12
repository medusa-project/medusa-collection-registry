class AddTreeCountToCfsDirectories < ActiveRecord::Migration
  def change
    add_column :cfs_directories, :tree_count, :integer, default: 0
  end
end
