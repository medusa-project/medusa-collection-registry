FactoryGirl.define do
  factory :producer do
    sequence(:title) {|n| "Sample Producer #{n}"}
    association :administrator, :factory => :person
    address_1 'Address 1'
    address_2 'Address 2'
    city 'Urbana'
    state 'Illinois'
    zip '61801'
    phone_number '555-1234'
    email 'unit@example.com'
    sequence(:url) {|n| "http://producer-#{n}.example.com"}
    sequence(:notes) {|n| "Sample notes #{n}"}
  end
end