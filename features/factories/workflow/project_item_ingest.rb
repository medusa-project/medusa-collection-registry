FactoryGirl.define do
  factory :workflow_project_item_ingest, class: Workflow::ProjectItemIngest do
    state 'start'
  end
end