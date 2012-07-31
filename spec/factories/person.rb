FactoryGirl.define do
  factory :person do
    sequence(:net_id) {|n| "Person #{n}"}
  end
end