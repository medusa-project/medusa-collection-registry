# spec/factories/assessor_task_elements.rb

FactoryBot.define do
  factory :assessor_task_element, class: 'Assessor::TaskElement' do
    association :cfs_file

    checksum { true }
    content_type { true }
    fits { true }
    sent_at { Time.current }
  end
end