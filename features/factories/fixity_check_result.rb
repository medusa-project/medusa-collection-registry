FactoryGirl.define do
  factory :fixity_check_result do
    cfs_file
    status 'ok'
  end
end