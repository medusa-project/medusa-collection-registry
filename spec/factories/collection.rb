FactoryGirl.define do
  factory :collection do
    sequence(:title) {|n| "Collection #{n}"}
    repository
    content_type ContentType.find_by_name('metadata')
    association :contact, :factory => :person
    preservation_priority_id PreservationPriority.default.id
  end
end