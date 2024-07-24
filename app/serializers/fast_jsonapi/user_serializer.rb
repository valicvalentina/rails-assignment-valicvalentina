module FastJsonapi
  class UserSerializer
    include FastJsonapi::ObjectSerializer

    attributes :first_name, :last_name, :email, :created_at, :updated_at

    attribute :id, &:id

    has_many :bookings, serializer: FastJsonapi::BookingSerializer
  end
end
