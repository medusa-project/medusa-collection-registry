class AddAmazonBackupToWorkflowProjectItemIngests < ActiveRecord::Migration
  def change
    add_column :workflow_project_item_ingests, :amazon_backup_id, :integer
  end
end
