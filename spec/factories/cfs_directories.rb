#spec/factories/cfs_directories.rb
FactoryBot.define do
  factory :cfs_directory do
    sequence(:path) { |n| "cfs_subdir_#{n}" }

    trait :with_parent_file_group do
      association :parent, factory: :file_group
      parent_type { 'FileGroup' }

      after(:create) do |dir|
       # Set the root_cfs_directory to itself if not already set
        dir.root_cfs_directory ||= dir
      end
    end

    trait :with_parent_directory do
      association :parent, factory: :cfs_directory
      parent_type { 'CfsDirectory' }

      after(:create) do |dir|
        dir.root_cfs_directory ||= dir.parent&.root_cfs_directory
      end
    end
  end
end

