FactoryBot.define do
  factory :booking do
    no_of_seats { 1 }
    seat_price { 300.00 }
    association :user
    association :flight
  end
end
