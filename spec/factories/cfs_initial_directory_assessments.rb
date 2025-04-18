# spec/factories/cfs_initial_directory_assessments.rb
FactoryBot.define do
  factory :cfs_initial_directory_assessment, class: 'Job::CfsInitialDirectoryAssessment' do
    association :file_group
    association :cfs_directory
  end
end