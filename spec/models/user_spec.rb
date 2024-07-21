RSpec.describe User, type: :model do
  let!(:user) { create(:user, email: 'user.useric@gmail.com') }

  it 'is valid with all attributes' do
    expect(user).to be_valid
  end

  it { is_expected.to validate_presence_of(:first_name) }

  it 'is invalid with a short first_name' do
    user = build(:user, first_name: 'V')
    user.valid?
    expect(user.errors[:first_name]).to include('is too short (minimum is 2 characters)')
  end

  it { is_expected.to validate_presence_of(:email) }

  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

  it 'is invalid with an improperly formatted email' do
    user = build(:user, email: 'valevalic.gmail')
    user.valid?
    expect(user.errors[:email]).to include('is invalid')
  end
end
