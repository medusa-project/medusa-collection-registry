FactoryGirl.define do
  factory :cfs_file do
    sequence(:name) {|n| "file_#{n}"}
    cfs_directory
    content_type
  end

  factory :attached_cfs_file, class: CfsFile do
    sequence(:name) {|n| "file_#{n}"}
    association :cfs_directory, factory: :attached_cfs_directory
    content_type
  end
end