module FastJsonapi
  class BookingSerializer
    include FastJsonapi::ObjectSerializer

    attributes :no_of_seats, :created_at, :updated_at

    attribute :id, &:id

    attribute :seat_price do |booking|
      booking.seat_price.to_f.to_i
    end

    has_one :user, serializer: FastJsonapi::UserSerializer
    has_one :flight, serializer: FastJsonapi::FlightSerializer
  end
end
