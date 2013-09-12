FactoryGirl.define do
  factory :package_profile do
    sequence(:name) {|n| "Package Profile #{n}"}
  end
end