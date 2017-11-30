#note that this factory makes no attempt to set up the various associations consistently
FactoryBot.define do
  factory :archived_accrual_job do
    sequence(:report) {|n| "Report #{n}"}
    file_group
    user
    amazon_backup
    cfs_directory
    sequence(:staging_path) {|n| "path/#{n}"}
    sequence(:workflow_accrual_job_id)
  end
end