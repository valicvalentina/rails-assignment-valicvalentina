require 'rails_helper'

RSpec.describe 'Companies API', type: :request do
  let!(:companies) { FactoryBot.create_list(:company, 3) }

  describe 'GET /api/companies' do
    it 'successfully returns a list of companies' do
      get '/api/companies'

      expect(response).to have_http_status(:ok)
      json_body = JSON.parse(response.body)
      expect(json_body['companies'].size).to eq(3)
    end
  end

  describe 'GET /api/companies/:id' do
    it 'returns a single company' do
      get "/api/companies/#{companies.first.id}"

      expect(response).to have_http_status(:ok)
      json_body = JSON.parse(response.body)
      expect(json_body).to include('name')
    end

    it 'returns status 404 if the company does not exist' do
      get '/api/companies/999999'

      expect(response).to have_http_status(:not_found)
      json_body = JSON.parse(response.body)
      expect(json_body).to include('error' => "Couldn't find Company")
    end
  end

  describe 'POST /api/companies' do
    let(:valid_attributes) { { company: { name: 'New Company' } } }

    context 'when the request is valid' do
      it 'creates a new company' do
        expect do
          post '/api/companies', params: valid_attributes
        end.to change(Company, :count).by(1)

        expect(response).to have_http_status(:created)
        json_body = JSON.parse(response.body)
        expect(json_body).to include('name' => 'New Company')
      end
    end

    context 'when the request is invalid' do
      before { post '/api/companies', params: { company: { name: '' } } }

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        json_body = JSON.parse(response.body)
        expect(json_body['errors']['name']).to include("can't be blank")
      end
    end
  end

  describe 'PUT /api/companies/:id' do
    let(:valid_attributes) { { company: { name: 'Updated' } } }

    context 'when the record exists' do
      it 'updates the company' do
        put "/api/companies/#{companies.first.id}", params: valid_attributes
        expect(response).to have_http_status(:ok)
        json_body = JSON.parse(response.body)
        expect(json_body).to include('name' => 'Updated')
      end
    end

    context 'when the request is invalid' do
      before { put "/api/companies/#{companies.first.id}", params: { company: { name: '' } } }

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        json_body = JSON.parse(response.body)
        expect(json_body['errors']['name']).to include("can't be blank")
      end
    end
  end

  describe 'DELETE /api/companies/:id' do
    it 'deletes the company' do
      expect do
        delete "/api/companies/#{companies.first.id}"
      end.to change(Company, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
