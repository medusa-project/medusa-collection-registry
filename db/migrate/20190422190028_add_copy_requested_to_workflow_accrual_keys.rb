class AddCopyRequestedToWorkflowAccrualKeys < ActiveRecord::Migration[5.2]
  def change
    add_column :workflow_accrual_keys, :copy_requested, :boolean, default: false
  end
end
