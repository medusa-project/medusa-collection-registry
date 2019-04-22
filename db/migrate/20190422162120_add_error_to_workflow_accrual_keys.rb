class AddErrorToWorkflowAccrualKeys < ActiveRecord::Migration[5.2]
  def change
    add_column :workflow_accrual_keys, :error, :text
  end
end
