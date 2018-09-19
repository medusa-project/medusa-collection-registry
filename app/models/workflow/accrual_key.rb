class Workflow::AccrualKey < ApplicationRecord

  belongs_to :workflow_accrual_job, class_name: 'Workflow::AccrualJob', foreign_key: 'workflow_accrual_job_id'

end
