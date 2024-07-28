require 'rails_helper'

RSpec.describe 'Flights API', type: :request do
  include TestHelpers::JsonResponse
  include TestHelpers::Headers

  let!(:company) { create(:company) }
  let!(:flights) { create_list(:flight, 3, company: company) }
  let(:admin) { create(:user, role: 'admin') }
  let(:user) { create(:user, role: nil) }

  describe 'GET /api/flights' do
    context 'when X-API-SERIALIZER-ROOT is 1' do
      it 'successfully returns a list of flights with root' do
        get '/api/flights', headers: { 'X-API-SERIALIZER-ROOT' => '1' }
        expect(response).to have_http_status(:ok)
        expect(json_body['flights'].size).to eq(3)
      end
    end

    context 'when X-API-SERIALIZER-ROOT is 0' do
      it 'successfully returns a list of flights without root' do
        get '/api/flights', headers: { 'X-API-SERIALIZER-ROOT' => '0' }
        expect(response).to have_http_status(:ok)
        expect(json_body.size).to eq(3)
      end
    end
  end

  describe 'GET /api/flights/:id' do
    context 'when using FastJsonapi' do
      it 'returns a single flight with FastJsonapi' do
        get "/api/flights/#{flights.first.id}", headers: { 'X-API-SERIALIZER' => 'fast_jsonapi' }
        expect(response).to have_http_status(:ok)

        expect(json_body['flight']['data']).to include(
          'attributes' => a_hash_including(
            'name', 'departs_at', 'arrives_at', 'base_price', 'no_of_seats'
          )
        )
      end
    end

    context 'when using Blueprinter' do
      it 'returns a single flight with Blueprinter' do
        get "/api/flights/#{flights.first.id}", headers: { 'X-API-SERIALIZER' => 'blueprinter' }
        expect(response).to have_http_status(:ok)

        expect(json_body['flight']).to include(
          'name', 'departs_at', 'arrives_at', 'base_price', 'no_of_seats'
        )
      end
    end

    it 'returns status 404 if the flight does not exist' do
      get '/api/flights/999999'

      expect(response).to have_http_status(:not_found)
      expect(json_body).to include('error' => "Couldn't find Flight")
    end
  end

  describe 'POST /api/flights' do
    let(:valid_attributes) do
      { flight: { name: 'Zagreb-Bratislava', no_of_seats: 330, departs_at: 1.day.from_now,
                  arrives_at: 2.days.from_now, base_price: 200, company_id: company.id } }
    end

    context 'when admin with valid attributes' do
      it 'creates a new flight' do
        expect do
          post '/api/flights', params: valid_attributes, headers: valid_headers(admin)
        end.to change(Flight, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_body['flight']).to include(
          'name' => 'Zagreb-Bratislava',
          'no_of_seats' => 330,
          'base_price' => 200
        )
      end
    end

    context 'when admin with invalid attributes' do
      it 'returns status code 400' do
        post '/api/flights', params: { flight: { name: '' } }, headers: valid_headers(admin)
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        post '/api/flights', params: { flight: { name: '' } }, headers: valid_headers(admin)
        expect(json_body['errors']['name']).to include("can't be blank")
      end
    end

    context 'when non-admin user with valid attributes' do
      it 'returns status 403 forbidden' do
        post '/api/flights', params: valid_attributes, headers: valid_headers(user)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when non-admin user with invalid attributes' do
      it 'returns status 403 forbidden' do
        post '/api/flights', params: { flight: { name: '' } }, headers: valid_headers(user)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PUT /api/flights/:id' do
    let(:valid_attributes) { { flight: { name: 'Updated Flight' } } }

    context 'when admin with valid attributes' do
      it 'updates the flight' do
        put "/api/flights/#{flights.first.id}", params: valid_attributes,
                                                headers: valid_headers(admin)
        expect(response).to have_http_status(:ok)
        expect(json_body['flight']).to include('name' => 'Updated Flight')
      end
    end

    context 'when admin with invalid attributes' do
      it 'returns status code 400' do
        put "/api/flights/#{flights.first.id}", params: { flight: { name: '' } },
                                                headers: valid_headers(admin)
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        put "/api/flights/#{flights.first.id}", params: { flight: { name: '' } },
                                                headers: valid_headers(admin)
        expect(json_body['errors']['name']).to include("can't be blank")
      end
    end

    context 'when non-admin user with valid attributes' do
      it 'returns status 403 forbidden' do
        put "/api/flights/#{flights.first.id}", params: valid_attributes,
                                                headers: valid_headers(user)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when non-admin user with invalid attributes' do
      it 'returns status 403 forbidden' do
        put "/api/flights/#{flights.first.id}", params: { flight: { name: '' } },
                                                headers: valid_headers(user)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /api/flights/:id' do
    context 'when admin and the flight exists' do
      it 'deletes the flight' do
        expect do
          delete "/api/flights/#{flights.first.id}", headers: valid_headers(admin)
        end.to change(Flight, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when admin and the flight does not exist' do
      it 'returns a not found error' do
        non_existent_flight_id = 99_999
        delete "/api/flights/#{non_existent_flight_id}", headers: valid_headers(admin)
        expect(response).to have_http_status(:not_found)
        expect(json_body['error']).to eq("Couldn't find Flight")
      end
    end

    context 'when non-admin user' do
      it 'returns status 403 forbidden' do
        delete "/api/flights/#{flights.first.id}", headers: valid_headers(user)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
