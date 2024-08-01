class FlightCalculator
  attr_reader :flight

  def initialize(flight)
    @flight = flight
  end

  def current_price
    if days_until_departure >= 15
      flight.base_price
    else
      calculate_increased_price
    end.round
  end

  private

  def days_until_departure
    [(flight.departs_at.to_date - Time.zone.today).to_i, 0].max
  end

  def calculate_increased_price
    flight.base_price * (1 + (1.0 / 15) * (15 - days_until_departure))
  end
end
