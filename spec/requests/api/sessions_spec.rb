require 'rails_helper'

RSpec.describe 'Sessions API', type: :request do
  let!(:user) { create(:user, password: 'password123') }
  let(:valid_credentials) do
    {
      session: {
        email: user.email,
        password: 'password123'
      }
    }
  end

  let(:invalid_credentials) do
    {
      session: {
        email: 'wrong@example.com',
        password: 'wrongpassword'
      }
    }
  end

  describe 'POST /api/session' do
    context 'when the credentials are valid' do
      it 'returns a session token and user information' do
        post '/api/session', params: valid_credentials

        expect(response).to have_http_status(:created)

        json_body = JSON.parse(response.body)
        expect(json_body['session']).to include('token')
        expect(json_body['session']['user']).to include(
          'id',
          'first_name',
          'last_name',
          'email'
        )
      end
    end

    context 'when the credentials are invalid' do
      it 'returns an error message' do
        post '/api/session', params: invalid_credentials

        expect(response).to have_http_status(:bad_request)
        json_body = JSON.parse(response.body)
        expect(json_body['errors']).to include('credentials' => ['are invalid'])
      end
    end
  end
end
