#spec/factories/cfs_directories.rb
FactoryBot.define do
  factory :cfs_directory do
    sequence(:path) { |n| "cfs_subdir_#{n}" }
    
    trait :with_parent_file_group do
      association :parent, factory: :file_group
    end
  end
end
