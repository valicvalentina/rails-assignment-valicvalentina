class CompanySerializer < Blueprinter::Base
  identifier :id

  fields :name, :created_at, :updated_at

  field :no_of_active_flights do |company, _options|
    company.flights.where('departs_at > ?', Time.current).count
  end

  view :extended do
    association :flights, blueprint: FlightSerializer
  end
end
