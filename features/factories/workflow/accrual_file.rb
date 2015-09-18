FactoryGirl.define do
  factory :workflow_accrual_file, class: Workflow::AccrualFile do
    workflow_accrual_job
  end
end