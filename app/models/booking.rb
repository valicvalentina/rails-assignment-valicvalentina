class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :flight

  validates :seat_price, presence: true, numericality: { greater_than: 0 }
  validates :no_of_seats, presence: true, numericality: { greater_than: 0 }
  validate :flight_not_in_past
  validate :not_overbooked

  scope :with_active_flights, lambda {
    joins(:flight).where('flights.departs_at > ?', Time.current)
  }

  scope :ordered_by_flight_details, lambda {
    joins(:flight)
      .order('flights.departs_at ASC, flights.name ASC, bookings.created_at ASC')
  }
  def total_price
    no_of_seats * seat_price
  end

  private

  def flight_not_in_past
    return if flight.nil?

    errors.add(:flight, "can't be in the past") if flight.departs_at < DateTime.current
  end

  def not_overbooked
    return if flight.nil?

    booked_seats = flight.bookings.where.not(id: id).sum(:no_of_seats) + no_of_seats
    return unless booked_seats > flight.no_of_seats

    errors.add(:no_of_seats, 'Flight is overbooked')
  end
end
