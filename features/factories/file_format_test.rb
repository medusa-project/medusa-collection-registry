FactoryGirl.define do
  factory :file_format_test do
    sequence(:tester_email) {|n| "tester_#{n}@example.com"}
    date '2014-01-11'
    pass true
    cfs_file
    file_format_profile
  end
end