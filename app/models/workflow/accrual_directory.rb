class Workflow::AccrualDirectory < ActiveRecord::Base
  belongs_to :workflow_accrual_job

  validates_presence_of :workflow_accrual_job_id
  validates_uniqueness_of :name, scope: :workflow_accrual_job_id, allow_blank: false

end
