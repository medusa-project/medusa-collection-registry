FactoryGirl.define do
  factory :file_group do
    file_location 'Location'
    file_format 'image/jpeg'
    total_file_size 10
    total_files 100
    storage_medium StorageMedium.find_by_name('DVD')
    collection
  end
end