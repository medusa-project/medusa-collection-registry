FactoryGirl.define do
  factory :user do
    sequence(:uid) {|n| "user-#{n}"}
  end
end