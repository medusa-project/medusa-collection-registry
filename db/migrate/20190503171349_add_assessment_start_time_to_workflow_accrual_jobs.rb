class AddAssessmentStartTimeToWorkflowAccrualJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :workflow_accrual_jobs, :assessment_start_time, :datetime
  end
end
