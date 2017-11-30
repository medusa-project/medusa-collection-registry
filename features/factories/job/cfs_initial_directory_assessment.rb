FactoryBot.define do
  factory :cfs_initial_directory_assessment_job, class: Job::CfsInitialDirectoryAssessment do
    cfs_directory
    file_group
    file_count 1
  end
end