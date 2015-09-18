FactoryGirl.define do
  factory :job_ingest_staging_delete, class: Job::IngestStagingDelete do
    user
  end
end