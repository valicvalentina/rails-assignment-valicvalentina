RSpec.describe Flight, type: :model do
  subject(:flight) { build(:flight, company: company) }

  let(:company) { create(:company) }
  let(:first_flight) do
    create(:flight, company: company, departs_at: '2024-07-31 10:00:00',
                    arrives_at: '2024-07-31 12:00:00')
  end
  let(:second_flight) do
    build(:flight, company: company, departs_at: '2024-07-31 11:00:00',
                   arrives_at: '2024-07-31 13:00:00')
  end

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

  it 'is valid if departs_at is before arrives_at' do
    flight = build(:flight, departs_at: 1.day.from_now, arrives_at: 2.days.from_now,
                            company: company)
    expect(flight).to be_valid
  end

  it { is_expected.to validate_presence_of(:base_price) }

  it 'is invalid with a non-positive base_price' do
    flight = build(:flight, base_price: -1.00, company: company)
    flight.valid?
    expect(flight.errors[:base_price]).to include('must be greater than 0')
  end

  it 'is valid with a positive base_price' do
    flight = build(:flight, base_price: 1.00, company: company)
    expect(flight).to be_valid
  end

  it { is_expected.to validate_presence_of(:no_of_seats) }

  it 'is invalid with non-positive no_of_seats' do
    flight = build(:flight, no_of_seats: 0, company: company)
    flight.valid?
    expect(flight.errors[:no_of_seats]).to include('must be greater than 0')
  end

  it 'is valid with positive no_of_seats' do
    flight = build(:flight, no_of_seats: 1, company: company)
    expect(flight).to be_valid
  end

  describe 'check overlapping between flights in same company' do
    context 'when overlaps with another flight' do
      it 'contains errors on departs_at attribute' do
        first_flight
        second_flight.valid?
        expect(second_flight.errors.attribute_names).to include(:departs_at)
      end

      it 'contains errors on arrives_at attribute' do
        first_flight
        second_flight.valid?
        expect(second_flight.errors.attribute_names).to include(:arrives_at)
      end
    end

    context 'when does not overlap with another flight' do
      let(:third_flight) do
        build(:flight, company: company, departs_at: '2024-07-31 13:00:00',
                       arrives_at: '2024-07-31 15:00:00')
      end

      it 'does not contain errors on departs_at or arrives_at attribute' do
        third_flight.valid?
        expect(third_flight.errors.attribute_names).not_to include(:departs_at)
        expect(third_flight.errors.attribute_names).not_to include(:arrives_at)
      end
    end
  end
end
