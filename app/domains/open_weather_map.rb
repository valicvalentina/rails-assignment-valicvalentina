require 'net/http'
require 'json'
require_relative 'open_weather_map/city'
require_relative 'open_weather_map/resolver'

module OpenWeatherMap
  API_URL = 'https://api.openweathermap.org/data/2.5/weather'.freeze

  def self.city(city_name)
    city_id = Resolver.city_id(city_name)
    return nil unless city_id

    api_key = Rails.application.credentials.open_weather_map_api_key
    uri = URI("#{API_URL}?id=#{city_id}&appid=#{api_key}")
    response = Net::HTTP.get(uri)
    parsed_response = JSON.parse(response)

    City.parse(parsed_response)
  end
end
