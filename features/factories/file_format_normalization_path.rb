FactoryBot.define do
  factory :file_format_normalization_path do
    sequence(:name) {|n| "Name #{n}"}
    file_format
  end
end