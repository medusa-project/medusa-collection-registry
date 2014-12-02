FactoryGirl.define do
  factory :cfs_directory do
    sequence(:path) {|n| "cfs_subdir_#{n}"}
  end

  factory :attached_cfs_directory, parent: :cfs_directory do
    association :file_group, factory: :bit_level_file_group
  end
end
