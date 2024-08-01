RSpec.describe Booking, type: :model do
  let(:company) { create(:company, name: 'Test Company') }
  let(:flight) { create(:flight, company: company) }
  let(:user) { create(:user) }
  let!(:user_bookings) { create_list(:booking, 3, flight: flight, user: user) }
  let!(:admin_bookings) do
    create_list(:booking, 3, flight: flight, user: create(:user, role: 'admin'))
  end

  it 'is valid with all attributes' do
    booking = create(:booking, flight: flight, user: user, no_of_seats: 1, seat_price: 100.00)
    expect(booking).to be_valid
  end

  it { is_expected.to validate_presence_of(:seat_price) }

  it 'is invalid with a non-positive seat_price' do
    booking = build(:booking, flight: flight, user: user, no_of_seats: 1, seat_price: -5.00)
    booking.valid?
    expect(booking.errors[:seat_price]).to include('must be greater than 0')
  end

  it 'is valid with a positive seat_price' do
    booking = build(:booking, flight: flight, user: user, no_of_seats: 1, seat_price: 5.00)
    expect(booking).to be_valid
  end

  it { is_expected.to validate_presence_of(:no_of_seats) }

  it 'is invalid with non-positive no_of_seats' do
    booking = build(:booking, flight: flight, user: user, no_of_seats: 0, seat_price: 70.00)
    booking.valid?
    expect(booking.errors[:no_of_seats]).to include('must be greater than 0')
  end

  it 'is valid with positive no_of_seats' do
    booking = build(:booking, flight: flight, user: user, no_of_seats: 1, seat_price: 70.00)
    expect(booking).to be_valid
  end

  it 'is invalid if the flight departs in the past' do
    past_flight = build(:flight, :past, company: company)
    booking = build(:booking, flight: past_flight, user: user, no_of_seats: 1, seat_price: 100.00)
    booking.valid?
    expect(booking.errors[:flight]).to include("can't be in the past")
  end

  it 'is valid if the flight departs in the future' do
    booking = build(:booking, flight: flight, user: user, no_of_seats: 1, seat_price: 100.00)
    booking.valid?
    expect(booking).to be_valid
  end

  context 'when booking fetching' do
    it 'returns only the user\'s bookings if the user is not an admin' do
      expect(user.bookings.size).to eq(3)
      expect(user.bookings.pluck(:id)).to match_array(user_bookings.pluck(:id))
    end

    it 'returns all bookings if the user is an admin' do
      expect(admin_bookings.size).to eq(3)
      expect(described_class.all.size).to eq(6)
    end
  end

  context 'when testing overbooking' do
    it 'validates booking seats are within the flight capacity' do
      flight_seats = create(:flight, no_of_seats: 10)
      create(:booking, flight: flight_seats, no_of_seats: 5)
      booking = build(:booking, flight: flight_seats, no_of_seats: 6)
      expect(booking).not_to be_valid
      expect(booking.errors[:no_of_seats]).to include('Flight is overbooked')
    end

    it 'allows booking when seats are below capacity' do
      flight_seats = create(:flight, no_of_seats: 10)
      create(:booking, flight: flight_seats, no_of_seats: 5)
      booking = build(:booking, flight: flight_seats, no_of_seats: 3)
      expect(booking).to be_valid
    end

    it 'allows booking when seats are exactly at capacity' do
      flight_seats = create(:flight, no_of_seats: 10)
      create(:booking, flight: flight_seats, no_of_seats: 5)
      booking = build(:booking, flight: flight_seats, no_of_seats: 5)
      expect(booking).to be_valid
    end

    it 'allows booking when multiple bookings add up to exact capacity' do
      flight_seats = create(:flight, no_of_seats: 10)
      create(:booking, flight: flight_seats, no_of_seats: 4)
      create(:booking, flight: flight_seats, no_of_seats: 3)
      booking = build(:booking, flight: flight_seats, no_of_seats: 3)
      expect(booking).to be_valid
    end
  end

  it 'calculates total price correctly' do
    booking = create(:booking, no_of_seats: 3, seat_price: 200)
    expect(booking.total_price).to eq(600.00)
  end

  context 'when testing no_of_booked_seats' do
    it 'returns the total number of booked seats' do
      flight_seats = create(:flight)
      create(:booking, flight: flight_seats, no_of_seats: 3)
      create(:booking, flight: flight_seats, no_of_seats: 5)
      expect(flight_seats.no_of_booked_seats).to eq(8)
    end

    it 'returns 0 when there are no bookings' do
      flight_seats = create(:flight)
      expect(flight_seats.no_of_booked_seats).to eq(0)
    end
  end

  context 'when testing company_name' do
    it 'returns the company name when company exists' do
      expect(flight.company_name).to eq('Test Company')
    end

    it 'returns "No Company" when non-existing company' do
      flight_without_company = build(:flight, company: nil)
      expect(flight_without_company.company_name).to eq('No Company')
    end
  end
end
