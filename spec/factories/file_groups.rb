# spec/factories/file_groups.rb
FactoryBot.define do
  factory :file_group do
    title { "Test File Group" }
    description { "File group description" }
    association :collection
    producer { create(:producer) }
    total_files { 0 }
    total_file_size { nil } 
  end

  factory :bit_level_file_group, parent: :file_group, class: BitLevelFileGroup do
    type { 'BitLevelFileGroup' }
  end
end
