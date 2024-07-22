RSpec.describe Company, type: :model do
  let!(:company) { create(:company, name: 'Productive') }

  it 'is valid with all attributes' do
    expect(company).to be_valid
  end

  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end
