FactoryBot.define do
  factory :access_system do
    sequence(:name) {|n| "Access System #{n}"}
  end
end