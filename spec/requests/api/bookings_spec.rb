require 'rails_helper'

RSpec.describe 'Bookings API', type: :request do
  include TestHelpers::JsonResponse
  include TestHelpers::Headers

  let!(:company) { create(:company) }
  let!(:flight) { create(:flight, company: company) }
  let!(:admin)  { create(:user, role: 'admin') }

  describe 'GET /api/bookings' do # u modele dodati spec koji gleda da je id = id od usera
    context 'when the user is an admin' do
      it 'returns all bookings' do
        create_list(:booking, 3, flight: flight, user: admin)
        create_list(:booking, 3, flight: flight, user: create(:user))
        get '/api/bookings', headers: valid_headers(admin)
        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].size).to eq(6)
      end
    end

    context 'when the user is not an admin' do
      it 'returns only their bookings' do
        user = create(:user)
        create_list(:booking, 3, flight: flight, user: user)
        create_list(:booking, 3, flight: flight, user: create(:user))
        get '/api/bookings', headers: valid_headers(user)
        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].size).to eq(3)
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
    context 'when the user is an admin' do
      it 'returns the booking' do
        booking = create(:booking, flight: flight, user: create(:user))
        get "/api/bookings/#{booking.id}", headers: valid_headers(admin)
        expect(response).to have_http_status(:ok)
        expect(json_body['booking']).to include('no_of_seats', 'seat_price')
      end
    end

    context 'when the user is not an admin' do
      it 'returns their booking' do
        user = create(:user)
        booking = create(:booking, flight: flight, user: user)
        get "/api/bookings/#{booking.id}", headers: valid_headers(user)
        expect(response).to have_http_status(:ok)
        expect(json_body['booking']).to include('no_of_seats', 'seat_price')
      end

      it 'returns forbidden for another user\'s booking' do
        user = create(:user)
        other_booking = create(:booking, flight: flight, user: create(:user))
        get "/api/bookings/#{other_booking.id}", headers: valid_headers(user)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when unauthenticated' do
      it 'returns 401 unauthorized' do
        booking = create(:booking, flight: flight, user: create(:user))
        get "/api/bookings/#{booking.id}", headers: invalid_headers
        expect(response).to have_http_status(:unauthorized)
        expect(json_body).to eq({ 'errors' => { 'token' => ['is invalid'] } })
      end
    end
  end

  describe 'POST /api/bookings' do
    let(:valid_attributes) do
      { booking: { no_of_seats: 2, seat_price: 150, flight_id: flight.id } }
    end

    context 'when the request is valid' do
      it 'creates a new booking' do
        user = create(:user)
        expect do
          post '/api/bookings', params: valid_attributes.merge(user_id: user.id),
                                headers: valid_headers(user)
        end.to change(Booking, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_body['booking']).to include('no_of_seats' => 2, 'seat_price' => 150)
      end
    end

    context 'when the request is invalid' do
      it 'returns status code 400' do
        user = create(:user)
        post '/api/bookings', params: { booking: { no_of_seats: nil } },
                              headers: valid_headers(user)
        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']['no_of_seats']).to include("can't be blank")
      end
    end

    context 'when unauthenticated' do
      it 'returns 401 unauthorized' do
        post '/api/bookings', params: valid_attributes
        expect(response).to have_http_status(:unauthorized)
        expect(json_body).to eq({ 'errors' => { 'token' => ['is invalid'] } })
      end
    end
  end

  describe 'PUT /api/bookings/:id' do
    let(:valid_attributes) { { booking: { no_of_seats: 3 } } }

    context 'when the user is an admin' do
      it 'updates the booking including user_id' do
        admin_booking = create(:booking, flight: flight, user: admin)
        other_user = create(:user)
        put "/api/bookings/#{admin_booking.id}",
            params: { booking: { no_of_seats: 3, user_id: other_user.id } },
            headers: valid_headers(admin)
        expect(response).to have_http_status(:ok)
        expect(json_body['booking']).to include('no_of_seats' => 3)
        expect(json_body['booking']['user']['id']).to eq(other_user.id)
      end
    end

    context 'when the user is not an admin' do
      it 'updates their own booking' do
        user = create(:user)
        booking = create(:booking, flight: flight, user: user)
        put "/api/bookings/#{booking.id}", params: valid_attributes, headers: valid_headers(user)
        expect(response).to have_http_status(:ok)
        expect(json_body['booking']).to include('no_of_seats' => 3)
      end

      it 'returns forbidden when trying to update user_id' do
        user = create(:user)
        booking = create(:booking, flight: flight, user: user)
        put "/api/bookings/#{booking.id}",
            params: { booking: { no_of_seats: 3, user_id: admin.id } }, headers: valid_headers(user)
        expect(response).to have_http_status(:forbidden)
      end

      it 'returns forbidden when trying to update another user\'s booking' do
        user = create(:user)
        other_booking = create(:booking, flight: flight, user: create(:user))
        put "/api/bookings/#{other_booking.id}", params: valid_attributes,
                                                 headers: valid_headers(user)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when unauthenticated' do
      it 'returns 401 unauthorized' do
        booking = create(:booking, flight: flight, user: create(:user))
        put "/api/bookings/#{booking.id}", params: valid_attributes
        expect(response).to have_http_status(:unauthorized)
        expect(json_body).to eq({ 'errors' => { 'token' => ['is invalid'] } })
      end
    end
  end

  describe 'DELETE /api/bookings/:id' do
    context 'when the user is an admin' do
      it 'deletes the booking from admin' do
        admin_booking = create(:booking, flight: flight, user: admin)
        expect do
          delete "/api/bookings/#{admin_booking.id}", headers: valid_headers(admin)
        end.to change(Booking, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end

      it 'deletes the booking from user' do
        user = create(:user)
        user_booking = create(:booking, flight: flight, user: user)
        expect do
          delete "/api/bookings/#{user_booking.id}", headers: valid_headers(admin)
        end.to change(Booking, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when the user is not an admin' do
      it 'deletes their own booking' do
        user = create(:user)
        booking = create(:booking, flight: flight, user: user)
        expect do
          delete "/api/bookings/#{booking.id}", headers: valid_headers(user)
        end.to change(Booking, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end

      it 'returns forbidden when trying to delete another user\'s booking' do
        user = create(:user)
        other_booking = create(:booking, flight: flight, user: create(:user))
        delete "/api/bookings/#{other_booking.id}", headers: valid_headers(user)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when unauthenticated' do
      it 'returns 401 unauthorized' do
        booking = create(:booking, flight: flight, user: create(:user))
        delete "/api/bookings/#{booking.id}", headers: invalid_headers
        expect(response).to have_http_status(:unauthorized)
        expect(json_body).to eq({ 'errors' => { 'token' => ['is invalid'] } })
      end
    end
  end
end
