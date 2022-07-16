FactoryBot.define do
  factory :collection do
    sequence(:title) {|n| "Collection #{n}"}
    repository
    association :contact, factory: :person
    association :rights_declaration, factory: [:rights_declaration, :belongs_to_collection]
  end
end