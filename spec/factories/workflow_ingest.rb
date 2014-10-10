FactoryGirl.define do
  factory :workflow_ingest, class: Workflow::Ingest do
    association :external_file_group
    association :user
    state 'start'
  end

  factory :copying_workflow_ingest, parent: :workflow_ingest do
    association :bit_level_file_group
    state 'copying'
  end

  factory :amazon_backup_workflow_ingest, parent: :workflow_ingest do
    association :bit_level_file_group
    state 'amazon_backup'
    after(:create) do |ingest|
      FactoryGirl.create(:amazon_backup, workflow_ingest: ingest, user: ingest.user,
                         cfs_directory: ingest.bit_level_file_group.cfs_directory,
                         date: Date.today)
    end
  end
end