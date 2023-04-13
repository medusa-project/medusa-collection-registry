class AddCopyStartTimeToWorkflowAccrualJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :workflow_accrual_jobs, :copy_start_time, :datetime
    Workflow::AccrualJob.all.each do |wf|
      wf.copy_start_time = Time.now.utc
      wf.save
    end
  end
end
