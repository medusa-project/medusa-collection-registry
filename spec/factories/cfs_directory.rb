FactoryGirl.define do
  factory :cfs_directory do
    sequence(:path) {|n| "cfs_subdir_#{n}"}
  end
end