FactoryBot.define do
  factory :job_cfs_directory_export, class: Job::CfsDirectoryExport do
    user
    cfs_directory
  end
end