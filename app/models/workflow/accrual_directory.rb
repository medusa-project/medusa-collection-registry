class Workflow::AccrualDirectory < ActiveRecord::Base
  belongs_to :workflow_accrual_job, class_name: 'Workflow::AccrualJob', foreign_key: 'workflow_accrual_job_id'

  validates_presence_of :workflow_accrual_job_id
  validates_uniqueness_of :name, scope: :workflow_accrual_job_id, allow_blank: false

  def comparator
    Comparator::DirectoryTree.new(File.join(workflow_accrual_job.staging_local_path, name),
                                  File.join(workflow_accrual_job.staging_remote_path, name))
  end

end
