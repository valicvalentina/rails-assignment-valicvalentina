class Flight < ApplicationRecord
  belongs_to :company
  has_many :bookings, dependent: :destroy
  validates :name, presence: true, uniqueness: { scope: :company_id, case_sensitive: false }
  validates :departs_at, presence: true
  validates :arrives_at, presence: true
  validate :departs_before_arrives
  validates :base_price, presence: true, numericality: { greater_than: 0 }
  validates :no_of_seats, presence: true, numericality: { greater_than: 0 }

  def departs_before_arrives
    return unless departs_at && arrives_at

    errors.add(:departs_at, 'must be before arrives_at') if departs_at >= arrives_at
  end
end
