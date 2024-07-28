class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_secure_password
  has_secure_token

  has_many :bookings, dependent: :destroy
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: VALID_EMAIL_REGEX }
  validates :first_name, presence: true, length: { minimum: 2 }
  validates :password, presence: true
  validates :role, inclusion: { in: ['admin', nil], message: '%<value>s is not a valid role' },
                   allow_nil: true

  def admin?
    role == 'admin'
  end

  def public?
    role.nil?
  end

  def regenerate_token
    self.token = SecureRandom.hex(10)
    save(validate: false)
  end
end
