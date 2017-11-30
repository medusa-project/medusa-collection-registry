FactoryBot.define do
  factory :pronom do
    sequence(:pronom_id) {|n| "fmt/#{n}"}
    version '1.1'
  end
end