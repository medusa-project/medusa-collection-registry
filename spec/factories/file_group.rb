FactoryGirl.define do
  factory :file_group do
    sequence(:name) {|n| "File Group #{n}"}
    type 'ExternalFileGroup'
    external_file_location 'External File Location'
    total_files 0
    total_file_size 0
    collection
    producer
  end

  factory :external_file_group, parent: :file_group, class: ExternalFileGroup do
    type 'ExternalFileGroup'
  end

  factory :bit_level_file_group, parent: :file_group, class: BitLevelFileGroup do
    type 'BitLevelFileGroup'
    cfs_directory
  end

end

