FactoryBot.define do
  factory :file_format_profile do
    sequence(:name) {|n| "Name #{n}"}
  end
end