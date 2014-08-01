FactoryGirl.define do
  factory :user do
    sequence(:uid) {|n| "user-#{n}"}
    sequence(:email) {|n| "user#{n}@example.com"}
  end
end