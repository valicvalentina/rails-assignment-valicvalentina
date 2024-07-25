class FlightSerializer < Blueprinter::Base
  identifier :id

  fields :name, :no_of_seats, :departs_at, :arrives_at, :created_at, :updated_at

  field :base_price do |flight, _options|
    flight.base_price.to_f.to_i
  end

  view :extended do
    association :company, blueprint: CompanySerializer
    association :bookings, blueprint: BookingSerializer
  end

  def base_price
    object.base_price.to_f.to_i
  end
end
