require 'rails_helper'

RSpec.describe OpenWeatherMap::City do
  let(:city) { OpenWeatherMap::City.new(id: 2172797, lat: -16.92, lon: 145.77, temp_k: 300.15, name: 'Cairns') }

  describe 'attribute readers' do
    it 'initialises id correctly' do
      expect(city.id).to eq(2172797)
    end

    it 'initialises lat correctly' do
      expect(city.lat).to eq(-16.92)
    end

    it 'initialises lon correctly' do
      expect(city.lon).to eq(145.77)
    end

    it 'initialises temp_k correctly' do
      expect(city.temp_k).to eq(300.15)
    end

    it 'initialises name correctly' do
      expect(city.name).to eq('Cairns')
    end
  end

  describe '#temp' do
    it 'converts temperature from Kelvin to Celsius' do
      expect(city.temp).to eq(27.0)
    end
  end

  describe 'comparing objects' do
    let(:city_lower_temp) { OpenWeatherMap::City.new(id: 524901, lat: 55.75, lon: 37.62, temp_k: 295.0, name: 'Moscow') }
    let(:city_same_temp_first_name) { OpenWeatherMap::City.new(id: 524902, lat: 55.75, lon: 37.62, temp_k: 300.15, name: 'Athens') }
    let(:city_same_temp_same_name) { OpenWeatherMap::City.new(id: 2172797, lat: -16.92, lon: 145.77, temp_k: 300.15, name: 'Cairns') }
    let(:city_higher_temp) { OpenWeatherMap::City.new(id: 2172798, lat: -16.92, lon: 145.77, temp_k: 305.0, name: 'Brisbane') }
    let(:city_same_temp_second_name) { OpenWeatherMap::City.new(id: 524903, lat: 55.75, lon: 37.62, temp_k: 300.15, name: 'Zurich') }

    it 'returns true when receiver has a lower temperature' do
      expect(city_lower_temp < city).to be true
    end

    it 'returns true when receiver has the same temperature but name comes first alphabetically' do
      expect(city_same_temp_first_name < city).to be true
    end

    it 'returns false when receiver has the same temperature and name' do
      expect(city_same_temp_same_name == city).to be true
    end

    it 'returns true when receiver has a higher temperature' do
      expect(city_higher_temp > city).to be true
    end

    it 'returns true when receiver has the same temperature but name comes second alphabetically' do
      expect(city < city_same_temp_second_name).to be true
    end
  end

  describe '.parse' do
    let(:response) do
      {
        'coord' => { 'lon' => 145.77, 'lat' => -16.92 },
        'main' => { 'temp' => 300.15 },
        'id' => 2172797,
        'name' => 'Cairns'
      }
    end

    subject { described_class.parse(response) }

    it 'initializes the city with correct id' do
      expect(subject.id).to eq(2172797)
    end

    it 'initializes the city with correct latitude' do
      expect(subject.lat).to eq(-16.92)
    end

    it 'initializes the city with correct longitude' do
      expect(subject.lon).to eq(145.77)
    end

    it 'initializes the city with correct name' do
      expect(subject.name).to eq('Cairns')
    end

    it 'initializes the city with correct temperature in Kelvin' do
      expect(subject.temp_k).to eq(300.15)
    end

    it 'initializes the city with correct temperature in Celsius' do
      expect(subject.temp).to eq(27.0)
    end
  end
end