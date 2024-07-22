RSpec.describe Flight, type: :model do
  # using subject because that's the main object being tested
  subject(:flight) { build(:flight, company: company) }

  let(:company) { create(:company) }

  it 'is valid with all attributes' do
    expect(flight).to be_valid
  end

  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:company_id).case_insensitive }

  it { is_expected.to validate_presence_of(:departs_at) }

  it { is_expected.to validate_presence_of(:arrives_at) }

  it 'is invalid if departs_at is not before arrives_at' do
    flight = build(:flight, departs_at: 2.days.from_now, arrives_at: 1.day.from_now,
                            company: company)
    flight.valid?
    expect(flight.errors[:departs_at]).to include('must be before arrives_at')
  end

  it { is_expected.to validate_presence_of(:base_price) }

  it 'is invalid with a non-positive base_price' do
    flight = build(:flight, base_price: -1.00, company: company)
    flight.valid?
    expect(flight.errors[:base_price]).to include('must be greater than 0')
  end

  it { is_expected.to validate_presence_of(:no_of_seats) }

  it 'is invalid with non-positive no_of_seats' do
    flight = build(:flight, no_of_seats: 0, company: company)
    flight.valid?
    expect(flight.errors[:no_of_seats]).to include('must be greater than 0')
  end
end
