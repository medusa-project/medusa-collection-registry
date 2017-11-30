FactoryBot.define do
  factory :file_format do
    sequence(:name) {|n| "Name #{n}"}
    policy_summary 'Format policy'
  end
end