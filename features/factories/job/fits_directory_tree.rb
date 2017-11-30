FactoryBot.define do
  factory :fits_directory_tree_job, class: Job::FitsDirectoryTree do
    file_group
    cfs_directory
  end
  factory :job_fits_directory_tree, parent: :fits_directory_tree_job
end