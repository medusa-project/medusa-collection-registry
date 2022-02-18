class Workflow::AccrualKey < ApplicationRecord

  belongs_to :workflow_accrual_job, class_name: 'Workflow::AccrualJob', foreign_key: 'workflow_accrual_job_id'
  has_one :workflow_globus_transfer, class_name: 'Workflow::GlobusTransfer', dependent: :destroy, foreign_key: 'workflow_accrual_key_id'

  def self.copy_not_requested
    where(copy_requested: false)
  end

  def self.copy_requested
    where(copy_requested: true)
  end

  def self.has_error
    where('error IS NOT NULL')
  end

end
