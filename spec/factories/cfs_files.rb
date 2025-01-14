#spec/factories/cfs_files.rb
FactoryBot.define do
  factory :cfs_file do
    sequence(:name) { |n| "file_#{n}" }
    association :cfs_directory, factory: :cfs_directory
  end
end
