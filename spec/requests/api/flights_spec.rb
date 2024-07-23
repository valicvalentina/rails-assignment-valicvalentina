require 'rails_helper'

RSpec.describe 'Flights API', type: :request do
  let!(:company) { FactoryBot.create(:company) }
  let!(:flights) { FactoryBot.create_list(:flight, 3, company: company) }

  describe 'GET /api/flights' do
    it 'successfully returns a list of flights' do
      get '/api/flights'

      expect(response).to have_http_status(:ok)
      json_body = JSON.parse(response.body)
      expect(json_body['flights'].size).to eq(3)
    end
  end

  describe 'GET /api/flights/:id' do
    it 'returns a single flight' do
      get "/api/flights/#{flights.first.id}"

      expect(response).to have_http_status(:ok)
      json_body = JSON.parse(response.body)
      expect(json_body).to include('name', 'departs_at', 'arrives_at')
    end

    it 'returns status 404 if the flight does not exist' do
      get '/api/flights/999999'

      expect(response).to have_http_status(:not_found)
      json_body = JSON.parse(response.body)
      expect(json_body).to include('error' => "Couldn't find Flight")
    end
  end

  describe 'POST /api/flights' do
    let(:valid_attributes) do
      { flight: { name: 'Zagreb-Bratislava', no_of_seats: 330, departs_at: 1.day.from_now,
                  arrives_at: 2.days.from_now, base_price: 200.00, company_id: company.id } }
    end

    context 'when the request is valid' do
      it 'creates a new flight' do
        expect do
          post '/api/flights', params: valid_attributes
        end.to change(Flight, :count).by(1)

        expect(response).to have_http_status(:created)
        json_body = JSON.parse(response.body)
        expect(json_body).to include('name' => 'Zagreb-Bratislava')
      end
    end

    context 'when the request is invalid' do
      before { post '/api/flights', params: { flight: { name: '' } } }

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        json_body = JSON.parse(response.body)
        expect(json_body['errors']['name']).to include("can't be blank")
      end
    end
  end

  describe 'PUT /api/flights/:id' do
    let(:valid_attributes) { { flight: { name: 'Zagreb-Bratislava' } } }

    context 'when the record exists' do
      it 'updates the flight' do
        put "/api/flights/#{flights.first.id}", params: valid_attributes
        expect(response).to have_http_status(:ok)
        json_body = JSON.parse(response.body)
        expect(json_body).to include('name' => 'Zagreb-Bratislava')
      end
    end

    context 'when the request is invalid' do
      before { put "/api/flights/#{flights.first.id}", params: { flight: { name: '' } } }

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        json_body = JSON.parse(response.body)
        expect(json_body['errors']['name']).to include("can't be blank")
      end
    end
  end

  describe 'DELETE /api/flights/:id' do
    it 'deletes the flight' do
      expect do
        delete "/api/flights/#{flights.first.id}"
      end.to change(Flight, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
