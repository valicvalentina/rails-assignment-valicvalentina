require 'rails_helper'
require_relative '../../../app/domains/open_weather_map/resolver'

RSpec.describe OpenWeatherMap::Resolver, type: :module do
  before do
    @city_ids = [
      { "id" => 524901, "name" => "Zagreb" },
      { "id" => 703448, "name" => "Stuttgart" },
      { "id" => 2643743, "name" => "Karlovac" }
    ]

    allow(File).to receive(:read).and_return(@city_ids.to_json)
  end

  describe '.city_id' do
    it 'returns the correct id for a known city name' do
      expect(OpenWeatherMap::Resolver.city_id('Zagreb')).to eq(524901)
      expect(OpenWeatherMap::Resolver.city_id('Stuttgart')).to eq(703448)
      expect(OpenWeatherMap::Resolver.city_id('Karlovac')).to eq(2643743)
    end

    it 'returns nil for an unknown city name' do
      expect(OpenWeatherMap::Resolver.city_id('UnknownCity')).to be_nil
    end
  end
end