class Workflow::AccrualConflict < ActiveRecord::Base
  belongs_to :workflow_accrual_job,  class_name: 'Workflow::AccrualJob', foreign_key: 'workflow_accrual_job_id'

  def self.not_serious
    where(different: false)
  end

  def self.serious
    where(different: true)
  end

end
