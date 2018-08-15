class AddEmptyFileReportToWorkflowAccrualJobs < ActiveRecord::Migration[5.1]
  def change
    add_column :workflow_accrual_jobs, :empty_file_report, :text, default: ''
  end
end
