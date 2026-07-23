FactoryBot.define do
  factory :workflow_accrual_directory, class: 'Workflow::AccrualDirectory' do
    association :workflow_accrual_job, factory: :workflow_accrual_job

    sequence(:name) { |n| "package_#{n}" }
    size { 200.0 }
    count { 2 }
  end
end