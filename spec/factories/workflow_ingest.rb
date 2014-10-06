FactoryGirl.define do
  factory :workflow_ingest, class: Workflow::Ingest do
    association :external_file_group
    bit_level_file_group nil
    association :user
    state 'start'
  end
end