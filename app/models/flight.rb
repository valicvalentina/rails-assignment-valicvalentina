class Flight < ApplicationRecord
  belongs_to :company
  has_many :bookings, dependent: :destroy
  validates :name, presence: true, uniqueness: { scope: :company_id, case_sensitive: false }
  validates :departs_at, presence: true
  validates :arrives_at, presence: true
  validate :departs_before_arrives
  validates :base_price, presence: true, numericality: { greater_than: 0 }
  validates :no_of_seats, presence: true, numericality: { greater_than: 0 }
  validate :no_overlapping_flights, on: [:create, :update]

  scope :sorted, -> { order('departs_at ASC, name ASC, created_at ASC') }
  scope :active, -> { where('departs_at > ?', Time.current) }
  scope :by_name, ->(name) { where('LOWER(name) LIKE ?', "%#{name.downcase}%") }
  scope :by_departure_time, lambda { |time|
    truncated_time = truncate_to_minute(time)
    where("DATE_TRUNC('minute', departs_at) = ?", truncated_time)
  }
  scope :by_min_available_seats, lambda { |min_seats|
    joins('LEFT JOIN bookings ON bookings.flight_id = flights.id')
      .group('flights.id')
      .having('flights.no_of_seats - COALESCE(SUM(bookings.no_of_seats), 0) >= ?', min_seats)
      .select('flights.*, COALESCE(SUM(bookings.no_of_seats), 0) AS booked_seats')
  }

  def departs_before_arrives
    return unless departs_at && arrives_at

    errors.add(:departs_at, 'must be before arrives_at') if departs_at >= arrives_at
  end

  def self.truncate_to_minute(time)
    time.to_datetime.beginning_of_minute
  end

  def no_overlapping_flights
    overlapping_flights = Flight.where(company_id: company_id)
                                .where.not(id: id)
                                .where('departs_at < ? AND arrives_at > ?', arrives_at, departs_at)

    return unless overlapping_flights.exists?

    add_errors(overlapping_flights)
  end

  def add_errors(overlapping_flights)
    add_departure_error(overlapping_flights) if overlapping_flights.where('departs_at < ?',
                                                                          arrives_at).exists?
    add_arrival_error(overlapping_flights) if overlapping_flights.where('arrives_at > ?',
                                                                        departs_at).exists?
  end

  def add_departure_error(_overlapping_flights)
    errors.add(:departs_at, 'overlaps with another flight')
  end

  def add_arrival_error(_overlapping_flights)
    errors.add(:arrives_at, 'overlaps with another flight')
  end

  def current_price
    FlightCalculator.new(self).current_price
  end

  def company_name
    company.present? ? company.name : 'No Company'
  end

  def no_of_booked_seats
    bookings.present? ? bookings.sum(:no_of_seats) : 0
  end
end
