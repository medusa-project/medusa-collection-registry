class AddAmazonBackupIdToWorkflowIngests < ActiveRecord::Migration
  def change
    add_reference :workflow_ingests, :amazon_backup, index: true
  end
end
