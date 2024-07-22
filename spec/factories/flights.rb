FactoryBot.define do
  factory :flight do
    sequence(:name) { |n| "Flight-#{n}" }
    departs_at { 1.day.from_now }
    arrives_at { 2.days.from_now }
    base_price { 300.00 }
    no_of_seats { 100 }
    association :company

    trait :past do
      departs_at { 1.day.ago }
      arrives_at { DateTime.now }
    end
  end
end
