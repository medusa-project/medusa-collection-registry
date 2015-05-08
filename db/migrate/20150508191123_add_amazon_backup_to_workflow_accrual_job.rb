class AddAmazonBackupToWorkflowAccrualJob < ActiveRecord::Migration
  def change
    add_reference :workflow_accrual_jobs, :amazon_backup, index: true
    add_foreign_key :workflow_accrual_jobs, :amazon_backups
  end
end
