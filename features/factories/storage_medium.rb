FactoryGirl.define do
  factory :storage_medium do
    sequence(:name) {|n| "Medium #{n}"}
  end
end