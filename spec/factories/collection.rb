FactoryGirl.define do
  factory :collection do
    sequence(:title) {|n| "Collection #{n}"}
    repository
  end
end