FactoryGirl.define do
  factory :fits_file_job, class: Job::FitsFile do
    association :fits_directory_tree, factory: :fits_directory_tree_job
    sequence(:path) {|n| "file/path_#{n}/file_#{n}"}
  end
end