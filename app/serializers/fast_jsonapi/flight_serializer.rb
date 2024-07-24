module FastJsonapi
  class FlightSerializer
    include FastJsonapi::ObjectSerializer

    attributes :name, :no_of_seats, :departs_at, :arrives_at, :created_at, :updated_at

    attribute :id, &:id

    attribute :base_price do |flight|
      flight.base_price.to_f.to_i
    end

    belongs_to :company, serializer: FastJsonapi::CompanySerializer
    has_many :bookings, serializer: FastJsonapi::BookingSerializer
  end
end
