class AddAllowOverwriteToWorkflowAccrualJobs < ActiveRecord::Migration[5.1]
  def change
    add_column :workflow_accrual_jobs, :allow_overwrite, :boolean, default: false
  end
end
