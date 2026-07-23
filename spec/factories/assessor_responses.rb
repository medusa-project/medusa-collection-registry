# spec/factories/assessor_responses.rb

FactoryBot.define do
  factory :assessor_response, class: 'Assessor::Response' do
    association :assessor_task_element

    subtask { 'checksum' }
    status { 'handled' }
    success { true }
    content { '{}' }
  end
end