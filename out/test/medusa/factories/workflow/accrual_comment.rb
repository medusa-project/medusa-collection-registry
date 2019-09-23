FactoryBot.define do
  factory :workflow_accrual_comment, class: Workflow::AccrualComment do
    workflow_accrual_job
  end
end