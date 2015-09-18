FactoryGirl.define do
  factory :amazon_backup do
    cfs_directory
    user
    date {Date.today}
  end
end