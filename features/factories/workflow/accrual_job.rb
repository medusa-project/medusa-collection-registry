FactoryBot.define do
  factory :workflow_accrual_job, class: Workflow::AccrualJob do
    cfs_directory
    staging_path {'/staging/path/'}
    state {'start'}
    user
  end
end