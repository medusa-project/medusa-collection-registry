FactoryBot.define do
  factory :workflow_accrual_directory, class: Workflow::AccrualDirectory do
    workflow_accrual_job
  end
end