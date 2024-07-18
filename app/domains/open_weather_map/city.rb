module OpenWeatherMap
  class City
    include Comparable
    API_KEY = Rails.application.credentials.open_weather_map_api_key
    API_URL = 'https://api.openweathermap.org/data/2.5/find'.freeze
    attr_reader :id, :lat, :lon, :temp_k, :name

    def initialize(id:, lat:, lon:, temp_k:, name:)
      @id = id
      @lat = lat
      @lon = lon
      @temp_k = temp_k
      @name = name
    end

    def temp
      (@temp_k - 273.15).round(2)
    end

    def <=>(other)
      if temp < other.temp
        -1
      elsif temp > other.temp
        1
      else
        name <=> other.name
      end
    end

    def self.parse(city_data)
      new(id: city_data['id'], lat: city_data['coord']['lat'], lon: city_data['coord']['lon'],
          temp_k: city_data['main']['temp'], name: city_data['name'])
    end

    def nearby(count = 5)
      uri = build_uri(count)
      response = Net::HTTP.get(uri)
      result = JSON.parse(response)
      result['list'].map { |city_data| self.class.parse(city_data) }
    end

    def build_uri(count)
      uri = URI(API_URL)
      params = {
        lat: lat,
        lon: lon,
        cnt: count,
        appid: OpenWeatherMap::API_KEY
      }
      uri.query = URI.encode_www_form(params)
      uri
    end

    def coldest_nearby(*args)
      nearby(*args).min
    end
  end
end
