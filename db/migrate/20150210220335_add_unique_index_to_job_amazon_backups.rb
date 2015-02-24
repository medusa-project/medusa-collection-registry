class AddUniqueIndexToJobAmazonBackups < ActiveRecord::Migration
  def change
    add_index :job_amazon_backups, :amazon_backup_id, unique: true
  end
end
