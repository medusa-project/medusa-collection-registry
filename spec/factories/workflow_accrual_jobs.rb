FactoryBot.define do
  factory :workflow_accrual_job, class: 'Workflow::AccrualJob' do
    association :cfs_directory
    association :user

    staging_path { '/AVPres/Sousa/audio/' }
    state { 'assessing' }
    allow_overwrite { false }
    empty_file_report { '' }
  end
end