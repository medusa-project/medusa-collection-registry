FactoryGirl.define do
  factory :virus_scan_job, class: Job::VirusScan do
    file_group
  end
end