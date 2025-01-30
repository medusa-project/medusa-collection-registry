# spec/factories/virtual_repositories.rb
FactoryBot.define do
  factory :virtual_repository do
    sequence(:title) {|n| "Sample Virtual Repository #{n}"}
    association :repository
  end
end
