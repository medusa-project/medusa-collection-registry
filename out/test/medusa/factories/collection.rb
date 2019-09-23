FactoryBot.define do
  factory :collection do
    sequence(:title) {|n| "Collection #{n}"}
    repository
    association :contact, factory: :person
  end
end