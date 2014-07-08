class AddArchiveIdsToAmazonBackups < ActiveRecord::Migration
  def up
    add_column :amazon_backups, :archive_ids, :text
    AmazonBackup.all.each do |backup|
      backup.archive_ids ||= Array.new
      backup.save!
    end
  end

  def down
    remove_column :amazon_backups, :archive_ids
  end
end
