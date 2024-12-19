# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    uid { email }

    # Define traits for different roles
    trait :superuser do
      email { "superuser@example.com" }
      uid { email }
    end

    trait :project_admin do
      email { "projectadmin@example.com" }
      uid { email }
    end

    trait :medusa_admin do
      email { "medusaadmin@example.com" }
      uid { email }
    end

    trait :regular_user do
      email { "user@example.com" }
      uid { email }
    end

    trait :visitor do
      email { "visitor@example.com" }
      uid { email }
    end
  end
end
