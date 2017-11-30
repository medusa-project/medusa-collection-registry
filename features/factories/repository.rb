FactoryBot.define do
  factory :repository do
    sequence(:title) {|n| "Sample Repository #{n}"}
    sequence(:url) {|n| "http://sample-#{n}.example.com"}
    sequence(:notes) {|n| "Sample notes #{n}"}
    association :contact, factory: :person
    ldap_admin_domain 'uofi'
    ldap_admin_group 'manager'
    association :institution
  end
end