FactoryGirl.define do
  factory :project do
    sequence(:title) {|n| "Sample Project #{n}"}
    manager 'project_manager@example.com'
    owner 'project_owner@example.com'
    start_date '2015-09-16'
    status 'active'
    sequence(:specifications) {|n| "Project specifications #{n}"}
    sequence(:summary) {|n| "Project summary #{n}"}
  end
end