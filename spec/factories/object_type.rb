FactoryGirl.define do
  factory :object_type do
    sequence(:name) {|n| "Object type #{n}"}
  end
end