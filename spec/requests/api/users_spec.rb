require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let!(:users) { FactoryBot.create_list(:user, 3) }

  describe 'GET /api/users' do
    it 'successfully returns a list of users' do
      get '/api/users'

      expect(response).to have_http_status(:ok)
      json_body = JSON.parse(response.body)
      expect(json_body['users'].size).to eq(3)
    end
  end

  describe 'GET /api/users/:id' do
    it 'returns a single user' do
      get "/api/users/#{users.first.id}"

      expect(response).to have_http_status(:ok)
      json_body = JSON.parse(response.body)
      expect(json_body['user']).to include(
        'first_name',
        'email'
      )
    end

    it 'returns status 404 if the user does not exist' do
      get '/api/users/999999'

      expect(response).to have_http_status(:not_found)
      json_body = JSON.parse(response.body)
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
        json_body = JSON.parse(response.body)
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
        json_body = JSON.parse(response.body)
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
        json_body = JSON.parse(response.body)
        expect(json_body['user']).to include('first_name' => 'Sven')
      end
    end

    context 'when the request is invalid' do
      before { put "/api/users/#{users.first.id}", params: { user: { first_name: '' } } }

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        json_body = JSON.parse(response.body)
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
