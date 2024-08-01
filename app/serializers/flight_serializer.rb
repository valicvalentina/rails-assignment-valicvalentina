class FlightSerializer < Blueprinter::Base
  identifier :id

  fields :name, :no_of_seats, :departs_at, :arrives_at, :created_at, :updated_at

  field :base_price do |flight, _options|
    flight.base_price.to_f.to_i
  end

  field :no_of_booked_seats do |flight, _options|
    flight.no_of_booked_seats
  end

  field :company_name do |flight, _options|
    flight.company_name
  end

  field :current_price do |flight, _options|
    flight.current_price
  end

  view :extended do
    association :company, blueprint: CompanySerializer
    association :bookings, blueprint: BookingSerializer
  end

  def base_price
    object.base_price.to_f.to_i
  end
end
