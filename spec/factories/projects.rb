# spec/factories/projects.rb
FactoryBot.define do
  factory :project do
    title { "Test Project" }
    summary { "Test project summary." }
    specifications { "Specifications for the test project." }
    start_date { Date.today }
    status { "active" }

    association :manager, factory: :person
    association :owner, factory: :person
    association :collection
  end
end
