FactoryGirl.define do
  factory :job_ingest_staging_delete, class: Job::IngestStagingDelete do
    user
    association :external_file_group, factory: :external_file_group
  end
end