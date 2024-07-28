require 'rails_helper'

RSpec.describe 'Bookings API', type: :request do
  include TestHelpers::JsonResponse
  include TestHelpers::Headers

  let!(:company) { create(:company) }
  let!(:flight) { create(:flight, company: company) }
  let!(:user) { create(:user) }
  let!(:bookings) { create_list(:booking, 3, flight: flight, user: user) }

  describe 'GET /api/bookings' do
    context 'when X-API-SERIALIZER-ROOT is 1' do
      it 'successfully returns a list of bookings with root' do
        get '/api/bookings', headers: valid_headers(user).merge('X-API-SERIALIZER-ROOT' => '1')
        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].size).to eq(3)
      end
    end

    context 'when X-API-SERIALIZER-ROOT is 0' do
      it 'successfully returns a list of bookings without root' do
        get '/api/bookings', headers: valid_headers(user).merge('X-API-SERIALIZER-ROOT' => '0')
        expect(response).to have_http_status(:ok)
        expect(json_body.size).to eq(3)
      end
    end

    context 'when unauthenticated' do
      it 'returns 401 unauthorized' do
        get '/api/bookings', headers: invalid_headers
        expect(response).to have_http_status(:unauthorized)
        expect(json_body).to eq({ 'errors' => { 'token' => ['is invalid'] } })
      end
    end
  end

  describe 'GET /api/bookings/:id' do
    context 'when using FastJsonapi' do
      it 'returns a single booking with FastJsonapi' do
        get "/api/bookings/#{bookings.first.id}",
            headers: valid_headers(user).merge('X-API-SERIALIZER' => 'fast_jsonapi')
        expect(response).to have_http_status(:ok)
        expect(json_body['booking']['data']).to include(
          'attributes' => a_hash_including(
            'no_of_seats',
            'seat_price'
          )
        )
      end
    end

    context 'when using Blueprinter' do
      it 'returns a single booking with Blueprinter' do
        get "/api/bookings/#{bookings.first.id}",
            headers: valid_headers(user).merge('X-API-SERIALIZER' => 'blueprinter')
        expect(response).to have_http_status(:ok)
        expect(json_body['booking']).to include(
          'no_of_seats',
          'seat_price'
        )
      end
    end

    it 'returns status 404 if the booking does not exist' do
      get '/api/bookings/999999', headers: valid_headers(user)
      expect(response).to have_http_status(:not_found)
      expect(json_body).to include('error' => "Couldn't find Booking")
    end

    context 'when unauthenticated' do
      it 'returns 401 unauthorized' do
        get "/api/bookings/#{bookings.first.id}", headers: invalid_headers
        expect(response).to have_http_status(:unauthorized)
        expect(json_body).to eq({ 'errors' => { 'token' => ['is invalid'] } })
      end
    end

    context 'when authenticated but unauthorized' do
      it 'returns 404 not found trying to access another user\'s booking' do
        other_user = create(:user)
        other_booking = create(:booking, user: other_user, flight: flight)
        get "/api/bookings/#{other_booking.id}", headers: valid_headers(user)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /api/bookings' do
    let(:valid_attributes) do
      { booking: { no_of_seats: 2, seat_price: 150, flight_id: flight.id, user_id: user.id } }
    end

    context 'when the request is valid' do
      it 'creates a new booking' do
        expect do
          post '/api/bookings', params: valid_attributes, headers: valid_headers(user)
        end.to change(Booking, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_body['booking']).to include('no_of_seats' => 2, 'seat_price' => 150)
      end
    end

    context 'when the request is invalid' do
      before do
        post '/api/bookings', params: { booking: { no_of_seats: nil } },
                              headers: valid_headers(user)
      end

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        expect(json_body['errors']['no_of_seats']).to include("can't be blank")
      end
    end

    context 'when unauthenticated' do
      it 'returns 401 unauthorized' do
        post '/api/bookings', params: valid_attributes, headers: invalid_headers
        expect(response).to have_http_status(:unauthorized)
        expect(json_body).to eq({ 'errors' => { 'token' => ['is invalid'] } })
      end
    end
  end

  describe 'PUT /api/bookings/:id' do
    let(:valid_attributes) { { booking: { no_of_seats: 3 } } }

    context 'when the request is valid' do
      it 'updates the booking' do
        put "/api/bookings/#{bookings.first.id}", params: valid_attributes,
                                                  headers: valid_headers(user)
        expect(response).to have_http_status(:ok)
        expect(json_body['booking']).to include('no_of_seats' => 3)
      end
    end

    context 'when the request is invalid' do
      before do
        put "/api/bookings/#{bookings.first.id}", params: { booking: { no_of_seats: nil } },
                                                  headers: valid_headers(user)
      end

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        expect(json_body['errors']['no_of_seats']).to include("can't be blank")
      end
    end

    context 'when unauthenticated' do
      it 'returns 401 unauthorized' do
        put "/api/bookings/#{bookings.first.id}", params: valid_attributes
        expect(response).to have_http_status(:unauthorized)
        expect(json_body).to eq({ 'errors' => { 'token' => ['is invalid'] } })
      end
    end
  end

  describe 'DELETE /api/bookings/:id' do
    context 'when the request is valid' do
      it 'deletes the booking' do
        expect do
          delete "/api/bookings/#{bookings.first.id}", headers: valid_headers(user)
        end.to change(Booking, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when the request is invalid' do
      it 'returns a not found error' do
        delete '/api/bookings/999999', headers: valid_headers(user)
        expect(response).to have_http_status(:not_found)
        expect(json_body['error']).to eq("Couldn't find Booking")
      end
    end

    context 'when unauthenticated' do
      it 'returns 401 unauthorized' do
        delete "/api/bookings/#{bookings.first.id}", headers: invalid_headers
        expect(response).to have_http_status(:unauthorized)
        expect(json_body).to eq({ 'errors' => { 'token' => ['is invalid'] } })
      end
    end
  end
end
