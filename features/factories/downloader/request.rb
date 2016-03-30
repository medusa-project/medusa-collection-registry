FactoryGirl.define do
  factory :downloader_request, class: 'Downloader::Request' do
    association :cfs_directory
    email 'user@example.com'
    status 'pending'
    downloader_id 'downloader_id'
  end
end