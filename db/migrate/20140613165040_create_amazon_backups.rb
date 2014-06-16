class CreateAmazonBackups < ActiveRecord::Migration
  def change
    create_table :amazon_backups do |t|
      t.integer :cfs_directory_id
      t.integer :part_count
      t.date :date
    end
    add_index :amazon_backups, :cfs_directory_id
  end
end
