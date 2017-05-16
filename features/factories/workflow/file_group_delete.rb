FactoryGirl.define do
  factory :workflow_file_group_delete, class: Workflow::FileGroupDelete do
    state 'start'
    association :file_group, factory: :bit_level_file_group
    association :requester, factory: :user
  end
end