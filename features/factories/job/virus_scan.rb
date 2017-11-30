FactoryBot.define do
  factory :virus_scan_job, class: Job::VirusScan do
    file_group
  end
  factory :job_virus_scan, parent: :virus_scan_job
end