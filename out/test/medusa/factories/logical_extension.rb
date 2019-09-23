FactoryBot.define do
  factory :logical_extension do
    sequence(:extension) {|n| "ext#{n}"}
    file_format
  end
end