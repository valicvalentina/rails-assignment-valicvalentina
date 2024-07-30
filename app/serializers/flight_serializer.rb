class FlightSerializer < Blueprinter::Base
  identifier :id

  fields :name, :no_of_seats, :departs_at, :arrives_at, :created_at, :updated_at

  field :base_price do |flight, _options|
    flight.base_price.to_f.to_i
  end

  field :no_of_booked_seats do |flight, _options|
    flight.bookings.present? ? flight.bookings.sum(:no_of_seats) : 0
  end

  field :company_name do |flight, _options|
    flight.company.present? ? flight.company.name : 'No Company'
  end

  field :current_price do |flight, _options|
    days_until_departure = (flight.departs_at.to_date - Time.zone.today).to_i

    current_price = if days_until_departure >= 15
                      flight.base_price
                    else
                      flight.base_price * (1 + (1.0 / 15) * (15 - days_until_departure))
                    end

    current_price.round
  end

  view :extended do
    association :company, blueprint: CompanySerializer
    association :bookings, blueprint: BookingSerializer
  end

  def base_price
    object.base_price.to_f.to_i
  end
end
