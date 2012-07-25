FactoryGirl.define do
  factory :assessment do
    sequence(:date) {|n| Date.parse('2000-01-01') + n.days}
    collection
  end
end