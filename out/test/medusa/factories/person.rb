FactoryBot.define do
  factory :person do
    sequence(:email) {|n| "person_#{n}@example.com"}
  end
end