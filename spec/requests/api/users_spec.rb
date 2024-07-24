require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  include TestHelpers::JsonResponse

  let!(:users) { create_list(:user, 3) }

  describe 'GET /api/users' do
    context 'when X-API-SERIALIZER-ROOT is 1' do
      before do
        get '/api/users', headers: { 'X-API-SERIALIZER-ROOT' => '1' }
      end

      it 'successfully returns a list of users with root' do
        expect(response).to have_http_status(:ok)
        expect(json_body['users'].size).to eq(3)
      end
    end

    context 'when X-API-SERIALIZER-ROOT is 0' do
      before do
        get '/api/users', headers: { 'X-API-SERIALIZER-ROOT' => '0' }
      end

      it 'successfully returns a list of users without root' do
        expect(response).to have_http_status(:ok)
        expect(json_body.size).to eq(3)
      end
    end
  end

  describe 'GET /api/users/:id' do
    context 'when using Blueprinter' do
      before do
        get "/api/users/#{users.first.id}", headers: { 'X-API-SERIALIZER' => 'blueprinter' }
      end

      it 'returns a single user with Blueprinter' do
        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include(
          'first_name',
          'email'
        )
      end
    end

    context 'when using FastJsonapi' do
      before do
        get "/api/users/#{users.first.id}", headers: { 'X-API-SERIALIZER' => 'fast_jsonapi' }
      end

      it 'returns a single user with FastJsonapi' do
        expect(response).to have_http_status(:ok)

        expect(json_body['user']['data']).to include(
          'attributes' => a_hash_including(
            'first_name',
            'email'
          )
        )
      end
    end

    it 'returns status 404 if the user does not exist' do
      get '/api/users/999999'

      expect(response).to have_http_status(:not_found)
      expect(json_body).to include('error' => "Couldn't find User")
    end
  end

  describe 'POST /api/users' do
    let(:valid_attributes) do
      { user: { first_name: 'Valentina', email: 'valentina.valic@gmail.com' } }
    end

    context 'when the request is valid' do
      it 'creates a new user' do
        expect do
          post '/api/users', params: valid_attributes
        end.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_body['user']).to include(
          'first_name' => 'Valentina',
          'email' => 'valentina.valic@gmail.com'
        )
      end
    end

    context 'when the request is invalid' do
      before { post '/api/users', params: { user: { first_name: '' } } }

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        expect(json_body['errors']['first_name']).to include(
          "can't be blank",
          'is too short (minimum is 2 characters)'
        )
      end
    end
  end

  describe 'PUT /api/users/:id' do
    let(:valid_attributes) { { user: { first_name: 'Sven' } } }

    context 'when the record exists' do
      it 'updates the user' do
        put "/api/users/#{users.first.id}", params: valid_attributes
        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('first_name' => 'Sven')
      end
    end

    context 'when the request is invalid' do
      before { put "/api/users/#{users.first.id}", params: { user: { first_name: '' } } }

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        expect(json_body['errors']['first_name']).to include(
          "can't be blank",
          'is too short (minimum is 2 characters)'
        )
      end
    end
  end

  describe 'DELETE /api/users/:id' do
    it 'deletes the user' do
      expect do
        delete "/api/users/#{users.first.id}"
      end.to change(User, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
