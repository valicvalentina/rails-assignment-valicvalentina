require 'rails_helper'

RSpec.describe 'Companies API', type: :request do
  include TestHelpers::JsonResponse
  include TestHelpers::Headers

  let!(:companies) { create_list(:company, 3) }
  let(:admin) { create(:user, role: 'admin') }
  let(:user) { create(:user, role: nil) }

  describe 'GET /api/companies' do
    context 'when X-API-SERIALIZER-ROOT is 1' do
      it 'successfully returns a list of companies with root' do
        get '/api/companies', headers: { 'X-API-SERIALIZER-ROOT' => '1' }
        expect(response).to have_http_status(:ok)
        expect(json_body['companies'].size).to eq(3)
      end
    end

    context 'when X-API-SERIALIZER-ROOT is 0' do
      it 'successfully returns a list of companies without root' do
        get '/api/companies', headers: { 'X-API-SERIALIZER-ROOT' => '0' }
        expect(response).to have_http_status(:ok)
        expect(json_body.size).to eq(3)
      end
    end
  end

  describe 'GET /api/companies/:id' do
    context 'when using FastJsonapi' do
      it 'returns a single company with FastJsonapi' do
        get "/api/companies/#{companies.first.id}",
            headers: { 'X-API-SERIALIZER' => 'fast_jsonapi' }
        expect(response).to have_http_status(:ok)

        expect(json_body['company']['data']).to include(
          'attributes' => a_hash_including(
            'name'
          )
        )
      end
    end

    context 'when using Blueprinter' do
      it 'returns a single company with Blueprinter' do
        get "/api/companies/#{companies.first.id}", headers: { 'X-API-SERIALIZER' => 'blueprinter' }
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

    context 'when admin with valid attributes' do
      it 'creates a new company' do
        expect do
          post '/api/companies', params: valid_attributes, headers: valid_headers(admin)
        end.to change(Company, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(json_body['company']).to include('name' => 'New Company')
      end
    end

    context 'when admin with invalid attributes' do
      it 'returns status code 400' do
        post '/api/companies', params: { company: { name: '' } }, headers: valid_headers(admin)
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        post '/api/companies', params: { company: { name: '' } }, headers: valid_headers(admin)
        expect(json_body['errors']['name']).to include("can't be blank")
      end
    end

    context 'when non-admin user with valid attributes' do
      it 'returns status 403 forbidden' do
        post '/api/companies', params: valid_attributes, headers: valid_headers(user)
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when non-admin user with invalid attributes' do
      it 'returns status 403 forbidden' do
        post '/api/companies', params: { company: { name: '' } }, headers: valid_headers(user)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /api/companies/:id' do
    let(:valid_attributes) { { company: { name: 'Updated' } } }

    context 'when admin with valid attributes' do
      it 'updates the company' do
        put "/api/companies/#{companies.first.id}", params: valid_attributes,
                                                    headers: valid_headers(admin)
        expect(response).to have_http_status(:ok)
        expect(json_body['company']).to include('name' => 'Updated')
      end
    end

    context 'when admin with invalid attributes' do
      it 'returns status code 400' do
        put "/api/companies/#{companies.first.id}", params: { company: { name: '' } },
                                                    headers: valid_headers(admin)
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        put "/api/companies/#{companies.first.id}", params: { company: { name: '' } },
                                                    headers: valid_headers(admin)
        expect(json_body['errors']['name']).to include("can't be blank")
      end
    end

    context 'when non-admin user with valid attributes' do
      it 'returns status 403 forbidden' do
        put "/api/companies/#{companies.first.id}", params: valid_attributes,
                                                    headers: valid_headers(user)
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user with invalid attributes' do
      it 'returns status 403 forbidden' do
        put "/api/companies/#{companies.first.id}", params: { company: { name: '' } },
                                                    headers: valid_headers(user)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/companies/:id' do
    context 'when admin and the company exists' do
      it 'deletes the company' do
        expect do
          delete "/api/companies/#{companies.first.id}", headers: valid_headers(admin)
        end.to change(Company, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when admin and the company does not exist' do
      it 'returns a not found error' do
        non_existent_company_id = 99_999
        delete "/api/companies/#{non_existent_company_id}", headers: valid_headers(admin)
        expect(response).to have_http_status(:not_found)
        expect(json_body['error']).to eq("Couldn't find Company")
      end
    end

    context 'when non-admin user' do
      it 'returns status 403 forbidden' do
        delete "/api/companies/#{companies.first.id}", headers: valid_headers(user)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
