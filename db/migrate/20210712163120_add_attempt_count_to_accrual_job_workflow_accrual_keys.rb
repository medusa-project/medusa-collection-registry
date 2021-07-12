class AddAttemptCountToAccrualJobWorkflowAccrualKeys < ActiveRecord::Migration[5.2]
  def change
    add_column :workflow_accrual_keys, :attempt_count, :integer, default: 0
  end
end
