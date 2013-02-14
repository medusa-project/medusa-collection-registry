FactoryGirl.define do
  factory :file_group do
    sequence(:name) {|n| "File Group #{n}"}
    storage_level 'external'
    external_file_location 'External File Location'
    file_type FileType.find_by_name('Other')
    collection
  end
end