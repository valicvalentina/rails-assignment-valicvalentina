require 'net/http'
require 'json'
require_relative 'open_weather_map/city'
require_relative 'open_weather_map/resolver'
module OpenWeatherMap
  API_KEY = Rails.application.credentials.open_weather_map_api_key
  API_URL = 'https://api.openweathermap.org/data/2.5/'.freeze

  def self.city(city_name)
    city_id = Resolver.city_id(city_name)
    return nil unless city_id

    uri = URI("#{API_URL}weather?id=#{city_id}&appid=#{API_KEY}")
    response = Net::HTTP.get(uri)
    parsed_response = JSON.parse(response)

    City.parse(parsed_response)
  end

  def self.cities(cities)
    city_id = cities.map { |city| Resolver.city_id(city) }.compact.join(',')
    uri = URI("#{API_URL}group?id=#{city_id}&appid=#{API_KEY}")
    response = Net::HTTP.get(uri)
    parsed_response = JSON.parse(response)
    parsed_response['list'].map { |city| City.parse(city) }
  end
end