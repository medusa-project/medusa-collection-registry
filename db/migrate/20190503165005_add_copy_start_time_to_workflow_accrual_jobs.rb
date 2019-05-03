class AddCopyStartTimeToWorkflowAccrualJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :workflow_accrual_jobs, :copy_start_time, :datetime
  end
end
