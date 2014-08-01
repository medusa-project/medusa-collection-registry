FactoryGirl.define do
  factory :person do
    sequence(:net_id) {|n| "person_#{n}@example.com"}
  end
end