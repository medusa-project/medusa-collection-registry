FactoryGirl.define do
  factory :event do
    sequence(:note) {|n| "Note #{n}"}
    association :eventable, :factory => :file_group
    actor_email 'admin@example.com'
    key 'external_staged'
    date {Date.today}
  end
end