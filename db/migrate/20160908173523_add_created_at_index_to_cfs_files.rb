class AddCreatedAtIndexToCfsFiles < ActiveRecord::Migration
  def change
    add_index :cfs_files, :created_at
  end
end
