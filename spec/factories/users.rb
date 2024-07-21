FactoryBot.define do
  factory :user do
    sequence(:first_name) { |n| "FirstName#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
  end
end
