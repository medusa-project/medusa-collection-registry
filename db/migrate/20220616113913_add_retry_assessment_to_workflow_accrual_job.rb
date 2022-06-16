class AddRetryAssessmentToWorkflowAccrualJob < ActiveRecord::Migration[5.2]
  def change
    add_column :workflow_accrual_jobs, :assessment_attempt_count, :integer
  end
end
