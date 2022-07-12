FactoryBot.define do
  factory :rights_declaration do
    trait :belongs_to_collection do
      rights_declarable_type { "Collection" }
    end
  end
end