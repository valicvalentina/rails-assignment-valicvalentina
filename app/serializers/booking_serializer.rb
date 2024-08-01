class BookingSerializer < Blueprinter::Base
  identifier :id

  fields :no_of_seats, :created_at, :updated_at

  field :seat_price do |booking, _options|
    booking.seat_price.to_f.to_i
  end

  field :total_price do |booking, _|
    booking.total_price
  end

  view :extended do
    association :user, blueprint: UserSerializer
    association :flight, blueprint: FlightSerializer
  end
end
