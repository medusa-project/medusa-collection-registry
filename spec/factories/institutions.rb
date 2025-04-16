# spec/factories/institutions.rb
FactoryBot.define do
  factory :institution do
    sequence(:name) { |n| "Institution #{n}" }
  end
end