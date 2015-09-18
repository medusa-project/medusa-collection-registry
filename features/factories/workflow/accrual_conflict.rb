FactoryGirl.define do
  factory :workflow_accrual_conflict, class: Workflow::AccrualConflict do
    workflow_accrual_job
  end
end