require 'rails_helper'

RSpec.describe 'Bookings API', type: :request do
  let!(:company) { FactoryBot.create(:company) }
  let!(:flight) { FactoryBot.create(:flight, company: company) }
  let!(:user) { FactoryBot.create(:user) }
  let!(:bookings) { FactoryBot.create_list(:booking, 3, flight: flight, user: user) }

  describe 'GET /api/bookings' do
    it 'successfully returns a list of bookings' do
      get '/api/bookings'

      expect(response).to have_http_status(:ok)
      json_body = JSON.parse(response.body)
      expect(json_body.size).to eq(3)
    end
  end

  describe 'GET /api/bookings/:id' do
    it 'returns a single booking' do
      get "/api/bookings/#{bookings.first.id}"

      expect(response).to have_http_status(:ok)
      json_body = JSON.parse(response.body)
      expect(json_body).to include('no_of_seats', 'seat_price')
    end

    it 'returns status 404 if the booking does not exist' do
      get '/api/bookings/999999'

      expect(response).to have_http_status(:not_found)
      json_body = JSON.parse(response.body)
      expect(json_body).to include('error' => "Couldn't find Booking")
    end
  end

  describe 'POST /api/bookings' do
    let(:valid_attributes) do
      { booking: { no_of_seats: 2, seat_price: 150.00, flight_id: flight.id, user_id: user.id } }
    end

    context 'when the request is valid' do
      it 'creates a new booking' do
        expect do
          post '/api/bookings', params: valid_attributes
        end.to change(Booking, :count).by(1)

        expect(response).to have_http_status(:created)
        json_body = JSON.parse(response.body)
        expect(json_body).to include('no_of_seats' => 2, 'seat_price' => '150.0')
      end
    end

    context 'when the request is invalid' do
      before { post '/api/bookings', params: { booking: { no_of_seats: nil } } }

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        json_body = JSON.parse(response.body)
        expect(json_body['errors']['no_of_seats']).to include("can't be blank")
      end
    end
  end

  describe 'PUT /api/bookings/:id' do
    let(:valid_attributes) { { booking: { no_of_seats: 3 } } }

    context 'when the record exists' do
      it 'updates the booking' do
        put "/api/bookings/#{bookings.first.id}", params: valid_attributes
        expect(response).to have_http_status(:ok)
        json_body = JSON.parse(response.body)
        expect(json_body).to include('no_of_seats' => 3)
      end
    end

    context 'when the request is invalid' do
      before { put "/api/bookings/#{bookings.first.id}", params: { booking: { no_of_seats: nil } } }

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        json_body = JSON.parse(response.body)
        expect(json_body['errors']['no_of_seats']).to include("can't be blank")
      end
    end
  end

  describe 'DELETE /api/bookings/:id' do
    it 'deletes the booking' do
      expect do
        delete "/api/bookings/#{bookings.first.id}"
      end.to change(Booking, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
