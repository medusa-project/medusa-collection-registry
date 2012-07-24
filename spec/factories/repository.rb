FactoryGirl.define do
  factory :repository do
    sequence(:title) {|n| "Sample Repository #{n}"}
    sequence(:url) {|n| "http://sample-#{n}.example.com"}
    sequence(:notes) {|n| "Sample notes #{n}"}
  end
end