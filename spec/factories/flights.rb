FactoryBot.define do
  factory :flight do
    sequence(:name) { |n| "Flight-#{n}" }
    departs_at { DateTime.now + 1.day }
    arrives_at { DateTime.now + 2.days }
    base_price { 300.00 }
    no_of_seats { 100 }
    association :company

    trait :past do
      departs_at { DateTime.now - 1.day }
      arrives_at { DateTime.now }
    end
  end
end
