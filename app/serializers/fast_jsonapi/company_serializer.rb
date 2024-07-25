module FastJsonapi
  class CompanySerializer
    include FastJsonapi::ObjectSerializer

    attributes :name, :created_at, :updated_at

    has_many :flights, serializer: FastJsonapi::FlightSerializer
  end
end
