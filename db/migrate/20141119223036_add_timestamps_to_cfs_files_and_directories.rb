class AddTimestampsToCfsFilesAndDirectories < ActiveRecord::Migration
  def change
    add_timestamps(:cfs_files)
    add_timestamps(:cfs_directories)
    CfsFile.update_all created_at: Time.now, updated_at: Time.now
    CfsDirectory.update_all created_at: Time.now, updated_at: Time.now
    add_index :cfs_files, :updated_at
    add_index :cfs_directories, :updated_at
  end
end
