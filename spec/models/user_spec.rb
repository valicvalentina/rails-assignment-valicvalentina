RSpec.describe User, type: :model do
  it 'is invalid without a first_name' do
    user = described_class.new(first_name: nil, last_name: 'Valic', email: 'vale.valic@gmail.com')
    user.valid?
    expect(user.errors[:first_name]).to include("can't be blank")
  end

  it 'is invalid with a short first_name' do
    user = described_class.new(first_name: 'V', last_name: 'Valic', email: 'vale.valic@gmail.com')
    user.valid?
    expect(user.errors[:first_name]).to include('is too short (minimum is 2 characters)')
  end

  it 'is invalid without an email' do
    user = described_class.new(first_name: 'Vale', last_name: 'Valic', email: nil)
    user.valid?
    expect(user.errors[:email]).to include("can't be blank")
  end

  it 'is invalid with a non-unique email' do
    described_class.create!(first_name: 'Vale', last_name: 'Valic', email: 'vale.valic@gmail.com')
    user = described_class.new(first_name: 'Sven', last_name: 'Valic',
                               email: 'vale.valic@gmail.com')
    user.valid?
    expect(user.errors[:email]).to include('has already been taken')
  end

  it 'is invalid with a non-unique email (case insensitive)' do
    described_class.create!(first_name: 'Vale', last_name: 'Valic', email: 'vale.valic@gmail.com')
    user = described_class.new(first_name: 'Vale', last_name: 'Valic',
                               email: 'vAle.VALic@gmail.com')
    user.valid?
    expect(user.errors[:email]).to include('has already been taken')
  end

  it 'is invalid with an improperly formatted email' do
    user = described_class.new(email: 'valevalic.gmail')
    user.valid?
    expect(user.errors[:email]).to include('is invalid')
  end
end
