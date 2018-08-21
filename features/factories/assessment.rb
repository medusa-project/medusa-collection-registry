FactoryBot.define do
  factory :assessment do
    sequence(:date) {|n| Date.parse('2000-01-01') + n.days}
    association :assessable, factory: :collection
    name {|n| "Assessment #{n}"}
    assessment_type {'external_files'}
    preservation_risk_level {'medium'}
    storage_medium
  end
end