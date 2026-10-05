# spec/factories/collections.rb
FactoryBot.define do
  factory :collection do
    sequence(:title) { |n| "Collection #{n}" }
    publish { true }
    description { "Test collection" }
    repository
    #association :contact, factory: :person

    # Ensure rights_declaration is only created if not already provided
    after(:build) do |collection, evaluator|
      # Use the repository passed into the factory if present
      collection.parent ||= collection.repository
      if collection.respond_to?(:rights_declaration) && collection.rights_declaration.nil?
        collection.rights_declaration = build(:rights_declaration, declarable: collection)
      end
    end

    trait :with_bit_level_file_groups do
      after(:create) do |collection|
        create_list(:bit_level_file_group, 2, collection: collection)
      end
    end

    trait :with_assessments do
      after(:create) do |collection|
        create_list(:assessment, 2, assessable: collection)
      end
    end

    trait :with_file_group_assessments do
      after(:create) do |collection|
        file_group = create(:file_group, collection: collection)
        create(:assessment, assessable: file_group)
      end
    end
  end
end
