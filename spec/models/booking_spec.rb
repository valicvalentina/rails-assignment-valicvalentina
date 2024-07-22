RSpec.describe Booking, type: :model do
  let(:company) { create(:company) }
  let(:flight) { create(:flight, company: company) }
  let(:user) { create(:user) }

  it 'is valid with all attributes' do
    booking = described_class.new(flight: flight, user: user, no_of_seats: 1,
                                  seat_price: 100.00)
    expect(booking).to be_valid
  end

  it { is_expected.to validate_presence_of(:seat_price) }

  it 'is invalid with a non-positive seat_price' do
    booking = described_class.new(flight: flight, user: user, no_of_seats: 1,
                                  seat_price: -5.00)
    booking.valid?
    expect(booking.errors[:seat_price]).to include('must be greater than 0')
  end

  it { is_expected.to validate_presence_of(:no_of_seats) }

  it 'is invalid with non-positive no_of_seats' do
    booking = described_class.new(flight: flight, user: user, no_of_seats: 0,
                                  seat_price: 70.00)
    booking.valid?
    expect(booking.errors[:no_of_seats]).to include('must be greater than 0')
  end

  it 'is invalid if the flight departs in the past' do
    past_flight = build(:flight, :past, company: company)
    booking = described_class.new(flight: past_flight, user: user, no_of_seats: 1,
                                  seat_price: 100.00)
    booking.valid?
    expect(booking.errors[:flight]).to include("can't be in the past")
  end
end
