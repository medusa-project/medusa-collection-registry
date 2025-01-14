# spec/factories/repositories.rb
FactoryBot.define do
  factory :repository do
    sequence(:title) { |n| "Repository Title #{n}" } 
    url { "" }
    email { "repository@test.com" }
    active_start_date { Date.today }
    active_end_date { Date.today + 1.year }
    institution

    trait :with_manager do
      transient do
        manager { nil } 
      end

      # Associate a manager with a repository
      after(:create) do |repository, evaluator|
        if evaluator.manager
          allow(repository).to receive(:manager?).with(evaluator.manager).and_return(true)
        end
      end
    end
  end
end
