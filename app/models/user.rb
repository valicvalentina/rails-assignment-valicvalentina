class User < ApplicationRecord
  has_many :bookings, dependent: :destroy
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true, length: { minimum: 2 }
end
