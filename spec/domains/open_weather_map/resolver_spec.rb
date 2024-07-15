require 'rails_helper'
require_relative '../../../app/domains/open_weather_map/resolver'

RSpec.describe OpenWeatherMap::Resolver, type: :module do
  let(:city_ids) do
    [
      { 'id' => 524_901, 'name' => 'Zagreb' },
      { 'id' => 703_448, 'name' => 'Stuttgart' },
      { 'id' => 2_643_743, 'name' => 'Karlovac' }
    ]
  end

  before do
    allow(File).to receive(:read).and_return(city_ids.to_json)
  end

  describe '.city_id' do
    it 'returns the correct id for a known city name' do
      expect(described_class.city_id('Zagreb')).to eq(524_901)
      expect(described_class.city_id('Stuttgart')).to eq(703_448)
      expect(described_class.city_id('Karlovac')).to eq(2_643_743)
    end

    it 'returns nil for an unknown city name' do
      expect(described_class.city_id('UnknownCity')).to be_nil
    end
  end
end
