FactoryGirl.define do
  factory :cfs_file do
    sequence(:name) {|n| "file_#{n}"}
    cfs_directory
    content_type
  end
end