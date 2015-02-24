FactoryGirl.define do
  factory :amazon_backup do
    association :cfs_directory
    association :user

  end

end