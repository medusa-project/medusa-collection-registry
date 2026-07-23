FactoryBot.define do
  factory :workflow_accrual_file, class: 'Workflow::AccrualFile' do
    association :workflow_accrual_job, factory: :workflow_accrual_job

    sequence(:name) { |n| "top_level_file_#{n}.txt" }
    size { 100.0 }
  end
end