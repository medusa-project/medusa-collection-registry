FactoryGirl.define do
  factory :related_file_group_join do
    association :source_file_group, factory: :external_file_group
    association :target_file_group, factory: :bit_level_file_group
  end
end