FactoryGirl.define do
  factory :file_format do
    sequence(:name) {|n| "Name #{n}"}
    sequence(:pronom_id) {|n| "fmt/#{n}"}
    policy_summary "Format policy"
  end
end