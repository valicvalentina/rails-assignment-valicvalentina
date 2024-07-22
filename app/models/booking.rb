class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :flight

  validates :seat_price, presence: true, numericality: { greater_than: 0 }
  validates :no_of_seats, presence: true, numericality: { greater_than: 0 }
  validate :flight_not_in_past

  private

  def flight_not_in_past
    return if flight.nil?

    errors.add(:flight, "can't be in the past") if flight.departs_at < DateTime.current
  end
end
