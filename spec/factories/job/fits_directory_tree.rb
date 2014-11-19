FactoryGirl.define do
  factory :fits_directory_tree_job, class: Job::FitsDirectoryTree do
    sequence(:path) {|n| "files/path_#{n}"}
  end
end