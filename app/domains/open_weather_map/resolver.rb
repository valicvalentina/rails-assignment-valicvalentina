require 'json'

module OpenWeatherMap
  module Resolver
    CITY_IDS_PATH = File.expand_path('city_ids.json', __dir__)

    def self.city_id(city_name)
      city_ids = JSON.parse(File.read(CITY_IDS_PATH))
      city = city_ids.find { |c| c['name'].casecmp(city_name).zero? }
      city ? city['id'] : nil
    end
  end
end