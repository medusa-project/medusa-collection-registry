class Workflow::AccrualFile < ApplicationRecord
  belongs_to :workflow_accrual_job, class_name: 'Workflow::AccrualJob', foreign_key: 'workflow_accrual_job_id'

  validates_presence_of :workflow_accrual_job_id
  validates_uniqueness_of :name, scope: :workflow_accrual_job_id, allow_blank: false

end
