module TestHelpers
  module JsonResponse
    def json_body
      JSON.parse(response.body)
    end
  end

  module Headers
    def valid_headers(user)
      { 'Authorization' => user.token }
    end

    def invalid_headers
      { 'Authorization' => 'Bearer invalid_token' }
    end
  end

  module FlightHelpers
    def calculate_expected_price(flight)
      days_until_departure = [(flight.departs_at.to_date - Time.zone.today).to_i, 0].max
      (flight.base_price * (1 + (1.0 / 15) * (15 - days_until_departure))).round
    end
  end
end
