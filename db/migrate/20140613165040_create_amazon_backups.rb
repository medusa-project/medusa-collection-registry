class CreateAmazonBackups < ActiveRecord::Migration
  def change
    create_table :amazon_backups do |t|
      t.integer :file_group_id
      t.integer :part_count
      t.date :date
    end
    add_index :amazon_backups, :file_group_id
  end
end
