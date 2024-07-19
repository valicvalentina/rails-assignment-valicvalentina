RSpec.describe Booking, type: :model do
  let(:company) { Company.create!(name: 'Productive') }
  let(:future_flight) do
    Flight.create!(
      name: 'Zagreb-Stuttgart',
      departs_at: DateTime.now + 1.day,
      arrives_at: DateTime.now + 2.days,
      base_price: 220.00,
      no_of_seats: 300,
      company: company
    )
  end

  let(:past_flight) do
    Flight.create!(
      name: 'Zagreb-Bratislava',
      departs_at: DateTime.now - 1.day,
      arrives_at: DateTime.now,
      base_price: 55.00,
      no_of_seats: 110,
      company: company
    )
  end

  it 'is invalid without a seat_price' do
    booking = described_class.new(flight: future_flight, user_id: 1, no_of_seats: 1,
                                  seat_price: nil)
    booking.valid?
    expect(booking.errors[:seat_price]).to include("can't be blank")
  end

  it 'is invalid with a non-positive seat_price' do
    booking = described_class.new(flight: future_flight, user_id: 1, no_of_seats: 1,
                                  seat_price: -5.00)
    booking.valid?
    expect(booking.errors[:seat_price]).to include('must be greater than 0')
  end

  it 'is invalid without no_of_seats' do
    booking = described_class.new(flight: future_flight, user_id: 1, no_of_seats: nil,
                                  seat_price: 70.00)
    booking.valid?
    expect(booking.errors[:no_of_seats]).to include("can't be blank")
  end

  it 'is invalid with non-positive no_of_seats' do
    booking = described_class.new(flight: future_flight, user_id: 1, no_of_seats: 0,
                                  seat_price: 70.00)
    booking.valid?
    expect(booking.errors[:no_of_seats]).to include('must be greater than 0')
  end

  it 'is invalid if the flight departs in the past' do
    booking = described_class.new(flight: past_flight, user_id: 1, no_of_seats: 1,
                                  seat_price: 100.00)
    booking.valid?
    expect(booking.errors[:flight]).to include("can't be in the past")
  end
end
