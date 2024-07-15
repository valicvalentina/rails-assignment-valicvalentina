require 'rails_helper'

RSpec.describe OpenWeatherMap::City do
  let(:city) do
    described_class.new(id: 2_172_797, lat: -16.92, lon: 145.77, temp_k: 300.15, name: 'Cairns')
  end

  describe 'attribute readers' do
    it 'initialises id correctly' do
      expect(city.id).to eq(2_172_797)
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
    let(:cities) do
      {
        lower_temp: described_class.new(id: 524_901, lat: 55.75, lon: 37.62, temp_k: 295.0,
                                        name: 'Moscow'),
        same_temp_first_name: described_class.new(id: 524_902, lat: 55.75, lon: 37.62,
                                                  temp_k: 300.15, name: 'Athens'),
        same_temp_same_name: described_class.new(id: 2_172_797, lat: -16.92, lon: 145.77,
                                                 temp_k: 300.15, name: 'Cairns'),
        higher_temp: described_class.new(id: 2_172_798, lat: -16.92, lon: 145.77, temp_k: 305.0,
                                         name: 'Brisbane'),
        same_temp_second_name: described_class.new(id: 524_903, lat: 55.75, lon: 37.62,
                                                   temp_k: 300.15, name: 'Zurich')
      }
    end

    it 'returns true when receiver has a lower temperature' do
      expect(cities[:lower_temp] < city).to be true
    end

    it 'returns true when receiver has the same temperature but name comes first alphabetically' do
      expect(cities[:same_temp_first_name] < city).to be true
    end

    it 'returns false when receiver has the same temperature and name' do
      expect(cities[:same_temp_same_name] == city).to be true
    end

    it 'returns true when receiver has a higher temperature' do
      expect(cities[:higher_temp] > city).to be true
    end

    it 'returns true when receiver has the same temperature but name comes second alphabetically' do
      expect(city < cities[:same_temp_second_name]).to be true
    end
  end

  describe '.parse' do
    subject(:parsed_city) { described_class.parse(parsed_response) }

    let(:parsed_response) do
      {
        'coord' => { 'lon' => 145.77, 'lat' => -16.92 },
        'main' => { 'temp' => 300.15 },
        'id' => 2_172_797,
        'name' => 'Cairns'
      }
    end

    it 'parses the response correctly' do
      expect(parsed_city.id).to eq(2_172_797)
      expect(parsed_city.lat).to eq(-16.92)
      expect(parsed_city.lon).to eq(145.77)
      expect(parsed_city.name).to eq('Cairns')
      expect(parsed_city.temp_k).to eq(300.15)
      expect(parsed_city.temp).to eq(27.0)
    end
  end
end
