# spec/factories/cfs_initial_file_group_assessments.rb
FactoryBot.define do
  factory :cfs_initial_file_group_assessment, class: 'Job::CfsInitialFileGroupAssessment' do
    association :file_group
  end
end