class CreateJobAmazonBackups < ActiveRecord::Migration
  def change
    create_table :job_amazon_backups do |t|
      t.integer :amazon_backup_id
    end
  end
end
