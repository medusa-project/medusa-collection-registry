# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { "testuser@illinois.edu" }
    uid { email }

    trait :project_admin do
      after(:build) do |user|
        user.define_singleton_method(:project_admin?) { true }
        user.define_singleton_method(:medusa_admin?) { false }
        user.define_singleton_method(:superuser?) { false }
      end
    end

    trait :repository_manager do
      transient do
        repository { nil } # Allow a repository to be passed during creation
      end
    
      after(:build) do |user, evaluator|
        if evaluator.repository
          # set up manager? method dynamically on the repository
          evaluator.repository.define_singleton_method(:manager?) do |u|
            u == user
          end
        end
    
        user.define_singleton_method(:project_admin?) { false }
        user.define_singleton_method(:medusa_admin?) { false }
        user.define_singleton_method(:superuser?) { false }
      end
    end

    trait :downloader do
      transient do
        permissible_collection_ids { [] }
      end
    
      after(:build) do |user, evaluator|
        user.define_singleton_method(:permissible_collection_ids) do
          evaluator.permissible_collection_ids
        end
      end
    end
    
  end
end
