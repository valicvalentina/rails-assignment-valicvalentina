require 'rails_helper'
require_relative '../../../app/domains/open_weather_map/resolver'

RSpec.describe OpenWeatherMap::Resolver, type: :module do
  let(:city_id) do
    [
      { 'id' => 524_901, 'name' => 'Zagreb' }
    ]
  end

  before do
    allow(File).to receive(:read).and_return(city_id.to_json)
  end

  describe '.city_id' do
    it 'returns the correct id for a known city name' do
      expect(described_class.city_id('Zagreb')).to eq(524_901)
    end

    it 'returns nil for an unknown city name' do
      expect(described_class.city_id('UnknownCity')).to be_nil
    end
  end
end
