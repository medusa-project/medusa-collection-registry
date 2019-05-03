class AddAssessmentStartTimeToWorkflowAccrualJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :workflow_accrual_jobs, :assessment_start_time, :datetime
    Workflow::AccrualJob.all.each do |wf|
      wf.assessment_start_time = Time.now
      wf.save
    end
  end
end
