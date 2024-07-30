FactoryBot.define do
  factory :user do
    sequence(:first_name) { |n| "FirstName#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:password) { |n| "Password#{n}" }
    sequence(:token) { |n| "token_#{n}" }
  end
end
