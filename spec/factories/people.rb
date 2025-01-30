# spec/factories/people.rb
FactoryBot.define do
  factory :person do
    sequence(:email) { |n| "person#{n}@example.com" }
  end
end