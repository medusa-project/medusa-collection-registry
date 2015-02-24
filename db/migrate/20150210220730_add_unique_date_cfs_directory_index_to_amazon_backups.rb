class AddUniqueDateCfsDirectoryIndexToAmazonBackups < ActiveRecord::Migration
  def change
    remove_index :amazon_backups, :cfs_directory_id
    add_index :amazon_backups, [:cfs_directory_id, :date], unique: true
  end
end
