FactoryGirl.define do
  factory :collection do
    sequence(:title) {|n| "Collection #{n}"}
    repository
    association :contact, factory: :person
    preservation_priority_id PreservationPriority.default.id
  end
end