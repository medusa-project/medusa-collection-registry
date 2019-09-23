FactoryBot.define do
  factory :content_type do
    sequence(:name) {|n| "application/octet_stream_#{n}"}
  end
end