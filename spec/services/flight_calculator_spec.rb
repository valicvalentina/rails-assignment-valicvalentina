require 'rails_helper'

RSpec.describe FlightCalculator, type: :service do
  include TestHelpers::FlightHelpers
  let(:flight) { create(:flight, base_price: 100, departs_at: departs_at, arrives_at: arrives_at) }
  let(:calculator) { described_class.new(flight) }

  describe '#current_price' do
    context 'when departs_at is more than or equal to 15 days from today' do
      let(:departs_at) { 16.days.from_now }
      let(:arrives_at) { 17.days.from_now }

      it 'returns the base price' do
        expect(calculator.current_price).to eq(100)
      end
    end

    context 'when departs_at is less than 15 days from today' do
      let(:departs_at) { 10.days.from_now }
      let(:arrives_at) { 11.days.from_now }

      it 'returns the calculated price' do
        expected_price = calculate_expected_price(flight)
        expect(calculator.current_price).to eq(expected_price)
      end
    end

    context 'when departs_at is today' do
      let(:departs_at) { Time.zone.today }
      let(:arrives_at) { 2.days.from_now }

      it 'returns double the base price' do
        expect(calculator.current_price).to eq(200)
      end
    end
  end
end
