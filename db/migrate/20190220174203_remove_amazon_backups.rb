require 'simple_trigger_helper'
class RemoveAmazonBackups < ActiveRecord::Migration[5.2]

  def up
    AmazonBackup.connection.execute('DROP VIEW IF EXISTS view_file_groups_latest_amazon_backup;')
    SimpleTriggerHelper.new(source_table: :workflow_accrual_jobs, target_table: :amazon_backups).drop_trigger
    SimpleTriggerHelper.new(source_table: :workflow_ingests, target_table: :amazon_backups).drop_trigger
    SimpleTriggerHelper.new(source_table: :amazon_backups, target_table: :cfs_directories).drop_trigger
    SimpleTriggerHelper.new(source_table: :amazon_backups, target_table: :users).drop_trigger
    remove_column :workflow_accrual_jobs, :amazon_backup_id
    remove_column :archived_accrual_jobs, :amazon_backup_id
    remove_column :workflow_ingests, :amazon_backup_id
    remove_column :workflow_project_item_ingests, :amazon_backup_id
    drop_table :amazon_backups
    drop_table :job_amazon_backups
  end

  #This is not a real down migration - it just does enough to allow rollback/migrate in case we need to
  # while developing.
  def down
    create_table :amazon_backups
    create_table :job_amazon_backups
    add_column :workflow_project_item_ingests, :amazon_backup_id, :integer
    add_column :workflow_ingests, :amazon_backup_id, :integer
    add_column :archived_accrual_jobs, :amazon_backup_id, :integer
    add_column :workflow_accrual_jobs, :amazon_backup_id, :integer
  end

end
