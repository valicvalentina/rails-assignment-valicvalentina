RSpec.describe Company, type: :model do
  it 'is invalid without a name' do
    company = described_class.new(name: nil)
    company.valid?
    expect(company.errors[:name]).to include("can't be blank")
  end

  it 'is invalid with a non-unique name' do
    described_class.create!(name: 'Productive')
    company = described_class.new(name: 'Productive')
    company.valid?
    expect(company.errors[:name]).to include('has already been taken')
  end

  it 'is invalid with a non-unique name (case insensitive)' do
    described_class.create!(name: 'Productive')
    company = described_class.new(name: 'productive')
    company.valid?
    expect(company.errors[:name]).to include('has already been taken')
  end
end
