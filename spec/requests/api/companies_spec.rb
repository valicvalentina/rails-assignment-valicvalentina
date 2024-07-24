require 'rails_helper'

RSpec.describe 'Companies API', type: :request do
  include TestHelpers::JsonResponse

  let!(:companies) { create_list(:company, 3) }

  describe 'GET /api/companies' do
    context 'when X-API-SERIALIZER-ROOT is 1' do
      before do
        get '/api/companies', headers: { 'X-API-SERIALIZER-ROOT' => '1' }
      end

      it 'successfully returns a list of companies with root' do
        expect(response).to have_http_status(:ok)
        expect(json_body['companies'].size).to eq(3)
      end
    end

    context 'when X-API-SERIALIZER-ROOT is 0' do
      before do
        get '/api/companies', headers: { 'X-API-SERIALIZER-ROOT' => '0' }
      end

      it 'successfully returns a list of companies without root' do
        expect(response).to have_http_status(:ok)
        expect(json_body.size).to eq(3)
      end
    end
  end

  describe 'GET /api/companies/:id' do
    context 'when using FastJsonapi' do
      before do
        get "/api/companies/#{companies.first.id}",
            headers: { 'X-API-SERIALIZER' => 'fast_jsonapi' }
      end

      it 'returns a single company with FastJsonapi' do
        expect(response).to have_http_status(:ok)

        expect(json_body['company']['data']).to include(
          'attributes' => a_hash_including(
            'name'
          )
        )
      end
    end

    context 'when using Blueprinter' do
      before do
        get "/api/companies/#{companies.first.id}", headers: { 'X-API-SERIALIZER' => 'blueprinter' }
      end

      it 'returns a single company with Blueprinter' do
        expect(response).to have_http_status(:ok)

        expect(json_body['company']).to include(
          'name'
        )
      end
    end

    it 'returns status 404 if the company does not exist' do
      get '/api/companies/999999'

      expect(response).to have_http_status(:not_found)
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
        expect(json_body['company']).to include('name' => 'New Company')
      end
    end

    context 'when the request is invalid' do
      before { post '/api/companies', params: { company: { name: '' } } }

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
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
        expect(json_body['company']).to include('name' => 'Updated')
      end
    end

    context 'when the request is invalid' do
      before { put "/api/companies/#{companies.first.id}", params: { company: { name: '' } } }

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
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
