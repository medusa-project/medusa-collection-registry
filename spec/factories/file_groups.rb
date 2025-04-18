FactoryBot.define do
  factory :file_group do
    title { "Test File Group" }
    description { "A description of the file group." }
    collection { create(:collection, repository: create(:repository)) }
    producer { create(:producer) }
    total_files { 0 }
    total_file_size { 0 }
  end

  factory :bit_level_file_group, parent: :file_group, class: 'BitLevelFileGroup' do
  end
end
