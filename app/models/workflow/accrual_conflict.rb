class Workflow::AccrualConflict < ActiveRecord::Base
  belongs_to :workflow_accrual_job,  class_name: 'Workflow::AccrualJob', foreign_key: 'workflow_accrual_job_id'

  def self.not_serious
    where(different: false)
  end

  def self.serious
    where(different: true)
  end

  def cfs_file
    workflow_accrual_job.cfs_directory.find_file_at_relative_path(path)
  end

  def reset_cfs_file
    file = try(:cfs_file)
    file.reset_fixity_and_fits!(actor_email: workflow_accrual_job.user.email) if file
  end

end
