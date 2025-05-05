# spec/factories/bit_level_file_groups.rb

FactoryBot.define do 
  factory :bit_level_file_group, parent: :file_group, class: 'BitLevelFileGroup' do 
    association :collection

    trait :with_cfs_directory do 
      after(:create) do |file_group| 
        file_group.ensure_cfs_directory
        file_group.reload
      end
    end
  end
end