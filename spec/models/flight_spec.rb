RSpec.describe Flight, type: :model do
  it 'is invalid without a name' do
    flight = described_class.new(name: nil, departs_at: DateTime.now + 1.day,
                                 arrives_at: DateTime.now + 2.days, base_price: 200.00,
                                 no_of_seats: 334, company_id: 1)
    flight.valid?
    expect(flight.errors[:name]).to include("can't be blank")
  end

  it 'is invalid with a non-unique name within the same company' do
    company = Company.create!(name: 'Productive')
    described_class.create!(name: 'Zagreb-Stuttgart', departs_at: DateTime.now + 1.day,
                            arrives_at: DateTime.now + 2.days, base_price: 100.00,
                            no_of_seats: 334, company_id: company.id)
    flight = described_class.new(name: 'Zagreb-Stuttgart', departs_at: DateTime.now + 1.day,
                                 arrives_at: DateTime.now + 2.days, base_price: 100.00,
                                 no_of_seats: 335, company_id: company.id)
    flight.valid?
    expect(flight.errors[:name]).to include('has already been taken')
  end

  it 'is invalid if without a departs_at' do
    flight = described_class.new(name: 'Zagreb-Stuttgart', departs_at: nil,
                                 arrives_at: DateTime.now + 1.day,
                                 base_price: 100.00, no_of_seats: 334, company_id: 1)
    flight.valid?
    expect(flight.errors[:departs_at]).to include("can't be blank")
  end

  it 'is invalid if without a arrives_at' do
    flight = described_class.new(name: 'Zagreb-Stuttgart', departs_at: DateTime.now + 2.days,
                                 arrives_at: nil, base_price: 100.00,
                                 no_of_seats: 334, company_id: 1)
    flight.valid?
    expect(flight.errors[:arrives_at]).to include("can't be blank")
  end

  it 'is invalid if departs_at is not before arrives_at' do
    flight = described_class.new(name: 'Zagreb-Stuttgart', departs_at: DateTime.now + 2.days,
                                 arrives_at: DateTime.now + 1.day, base_price: 100.00,
                                 no_of_seats: 334, company_id: 1)
    flight.valid?
    expect(flight.errors[:departs_at]).to include('must be before arrives_at')
  end

  it 'is invalid without a base_price' do
    flight = described_class.new(name: 'Zagreb-Stuttgart', departs_at: DateTime.now + 1.day,
                                 arrives_at: DateTime.now + 2.days, base_price: nil,
                                 no_of_seats: 223, company_id: 1)
    flight.valid?
    expect(flight.errors[:base_price]).to include("can't be blank")
  end

  it 'is invalid with a non-positive base_price' do
    flight = described_class.new(name: 'Zagreb-Roma', departs_at: DateTime.now + 1.day,
                                 arrives_at: DateTime.now + 2.days, base_price: -1.00,
                                 no_of_seats: 554, company_id: 1)
    flight.valid?
    expect(flight.errors[:base_price]).to include('must be greater than 0')
  end

  it 'is invalid without no_of_seats' do
    flight = described_class.new(name: 'Zagreb-Zurich', departs_at: DateTime.now + 1.day,
                                 arrives_at: DateTime.now + 2.days, base_price: 100.00,
                                 no_of_seats: nil, company_id: 1)
    flight.valid?
    expect(flight.errors[:no_of_seats]).to include("can't be blank")
  end

  it 'is invalid with non-positive no_of_seats' do
    flight = described_class.new(name: 'Zagreb-Zurich', departs_at: DateTime.now + 1.day,
                                 arrives_at: DateTime.now + 2.days, base_price: 300.00,
                                 no_of_seats: 0, company_id: 1)
    flight.valid?
    expect(flight.errors[:no_of_seats]).to include('must be greater than 0')
  end
end
