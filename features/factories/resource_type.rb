FactoryBot.define do
  factory :resource_type do
    sequence(:name) {|n| "Resource type #{n}"}
  end
end