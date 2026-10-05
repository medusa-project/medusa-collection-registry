# spec/factories/assessments.rb
FactoryBot.define do
  factory :assessment do
    sequence(:name) { |n| "Assessment #{n}" }
    assessable { nil }
    assessment_type { Assessment.assessment_types.first }
    preservation_risk_level { Assessment.risk_levels.first }

    trait :for_collection do
      association :assessable, factory: :collection
    end

    trait :for_file_group do
      association :assessable, factory: :file_group
    end
  end
end
