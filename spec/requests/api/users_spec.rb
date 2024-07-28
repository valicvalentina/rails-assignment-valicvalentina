require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  include TestHelpers::JsonResponse
  include TestHelpers::Headers

  let!(:users) { create_list(:user, 2) }
  let!(:user) { create(:user, role: nil) }
  let!(:admin) { create(:user, role: 'admin') }

  describe 'GET /api/users' do
    context 'when admin' do
      it 'successfully returns a list of users' do
        get '/api/users', headers: valid_headers(admin)
        expect(response).to have_http_status(:ok)
        expect(json_body['users'].size).to eq(4)
      end
    end

    context 'when non-admin' do
      it 'returns unauthorized status' do
        get '/api/users', headers: valid_headers(user)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/users/:id' do
    context 'when admin' do
      it 'returns a single user' do
        get "/api/users/#{user.id}", headers: valid_headers(admin)
        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('first_name', 'email')
      end
    end

    context 'when non-admin accessing own data' do
      it 'returns a single user' do
        get "/api/users/#{user.id}", headers: valid_headers(user)
        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('first_name', 'email')
      end
    end

    context 'when non-admin accessing another user data' do
      it 'returns forbidden status' do
        get "/api/users/#{users.last.id}", headers: valid_headers(user)
        expect(response).to have_http_status(:forbidden)
      end
    end

    it 'returns status 404 if the user does not exist' do
      get '/api/users/999999', headers: valid_headers(admin)
      expect(response).to have_http_status(:not_found)
      expect(json_body).to include('error' => "Couldn't find User")
    end
  end

  describe 'POST /api/users' do
    let(:valid_attributes) do
      { user: { first_name: 'Valentina', email: 'valentina.valic@gmail.com',
                password: 'Secret123' } }
    end

    context 'when admin with valid attributes' do
      it 'creates a new user' do
        expect do
          post '/api/users', params: valid_attributes, headers: valid_headers(admin)
        end.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_body['user']).to include('first_name' => 'Valentina',
                                             'email' => 'valentina.valic@gmail.com')
      end
    end

    context 'when admin with invalid attributes' do
      before do
        post '/api/users', params: { user: { first_name: '' } }, headers: valid_headers(admin)
      end

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

    context 'when non-admin' do
      it 'creates a new user' do
        post '/api/users', params: valid_attributes, headers: valid_headers(user)
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe 'PUT /api/users/:id' do
    let(:valid_attributes) { { user: { first_name: 'Sven', password: 'pass' } } }
    let(:valid_password) do
      { user: { password: 'new_password', password_confirmation: 'new_password' } }
    end

    context 'when admin' do
      it 'updates the user' do
        put "/api/users/#{user.id}", params: valid_attributes, headers: valid_headers(admin)
        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('first_name' => 'Sven')
      end

      it 'changes the user password' do
        put "/api/users/#{user.id}", params: valid_password, headers: valid_headers(admin)
        expect(response).to have_http_status(:ok)
        user.reload
        expect(user.authenticate('new_password')).to be_truthy
      end
    end

    context 'when non-admin updating own data' do
      it 'updates the user' do
        put "/api/users/#{user.id}", params: valid_attributes, headers: valid_headers(user)
        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('first_name' => 'Sven')
      end

      it 'changes the user password' do
        put "/api/users/#{user.id}", params: valid_password, headers: valid_headers(user)
        expect(response).to have_http_status(:ok)
        user.reload
        expect(user.authenticate('new_password')).to be_truthy
      end
    end

    context 'when non-admin updating another user data' do
      it 'returns forbidden status' do
        put "/api/users/#{users.last.id}", params: valid_attributes, headers: valid_headers(user)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when admin and the request is invalid' do
      before do
        put "/api/users/#{user.id}", params: { user: { first_name: '' } },
                                     headers: valid_headers(admin)
      end

      it 'returns status code 400 when first_name is blank' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message when first_name is blank' do
        expect(json_body['errors']['first_name']).to include(
          "can't be blank",
          'is too short (minimum is 2 characters)'
        )
      end
    end

    it 'returns status code 400 when the new_password is blank' do
      put "/api/users/#{user.id}", params: { user: { password: '', password_confirmation: '' } },
                                   headers: valid_headers(admin)
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a validation failure message when the new_password is blank' do
      put "/api/users/#{user.id}", params: { user: { password: '', password_confirmation: '' } },
                                   headers: valid_headers(admin)
      expect(json_body['errors']['password']).to include("can't be blank")
    end

    it 'returns status code 400 when the password is nil' do
      put "/api/users/#{user.id}", params: { user: { password: nil, password_confirmation: nil } },
                                   headers: valid_headers(admin)
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a validation failure message when the password is nil' do
      put "/api/users/#{user.id}", params: { user: { password: nil, password_confirmation: nil } },
                                   headers: valid_headers(admin)
      expect(json_body['errors']['password']).to include("can't be blank")
    end

    context 'when admin updating role attribute' do
      it 'updates the role attribute' do
        put "/api/users/#{user.id}", params: { user: { role: 'admin', password: 'pass' } },
                                     headers: valid_headers(admin)
        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('role' => 'admin')
      end
    end

    context 'when non-admin updating role attribute' do
      it 'returns forbidden status' do
        put "/api/users/#{user.id}", params: { user: { role: 'admin', password: 'pass' } },
                                     headers: valid_headers(user)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /api/users/:id' do
    context 'when admin' do
      it 'deletes the user' do
        expect do
          delete "/api/users/#{user.id}", headers: valid_headers(admin)
        end.to change(User, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when non-admin deleting own data' do
      it 'deletes the user' do
        expect do
          delete "/api/users/#{user.id}", headers: valid_headers(user)
        end.to change(User, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when non-admin deleting another user' do
      it 'returns forbidden status' do
        delete "/api/users/#{users.last.id}", headers: valid_headers(user)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when user does not exist' do
      it 'returns a not found error' do
        non_existent_user_id = 99_999
        delete "/api/users/#{non_existent_user_id}", headers: valid_headers(admin)
        expect(response).to have_http_status(:not_found)
        expect(json_body['error']).to eq("Couldn't find User")
      end
    end
  end
end
