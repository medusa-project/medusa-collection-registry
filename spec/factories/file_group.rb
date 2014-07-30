FactoryGirl.define do
  factory :file_group do
    sequence(:name) {|n| "File Group #{n}"}
    type 'ExternalFileGroup'
    external_file_location 'External File Location'
    file_type FileType.find_by_name('Other')
    total_files 0
    total_file_size 0
    collection
    producer
  end
end