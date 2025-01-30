# spec/factories/collections.rb
FactoryBot.define do
  factory :collection do
    sequence(:title) { |n| "Collection #{n}" }
    publish { true }
    description { "Test description for collection" }
    repository
  end
end