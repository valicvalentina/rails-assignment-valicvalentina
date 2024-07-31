require 'rails_helper'

RSpec.describe 'Bookings API', type: :request do
  include TestHelpers::JsonResponse
  include TestHelpers::Headers

  let!(:company) { create(:company) }
  let!(:flight) { create(:flight, company: company) }
  let!(:admin)  { create(:user, role: 'admin') }

  describe 'GET /api/bookings' do
    context 'when the user is an admin' do
      it 'returns all bookings' do
        create_list(:booking, 3, flight: flight, user: admin)
        create_list(:booking, 3, flight: flight, user: create(:user))
        get '/api/bookings', headers: valid_headers(admin)
        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].size).to eq(6)
      end
    end

    context 'when sorting by departs_at, flight name, and created_at' do
      it 'sort by departs_at ASC when different departs_at' do
        flight_munich_paris = create(:flight, name: 'Munich-Paris', departs_at: 1.day.from_now)
        flight_london_berlin = create(:flight, name: 'London-Berlin', departs_at: 2.days.from_now,
                                               arrives_at: 5.days.from_now)

        booking_alpha = create(:booking, flight: flight_munich_paris, created_at: 3.days.ago)
        booking_beta = create(:booking, flight: flight_london_berlin, created_at: 3.days.ago)

        get '/api/bookings', headers: valid_headers(admin)
        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].pluck('id')).to eq([booking_alpha.id, booking_beta.id])
      end

      it 'sort by flight_name ASC when same departs_at' do
        Flight.delete_all
        flight_a = create(:flight, name: 'A', departs_at: 1.day.from_now)
        flight_b = create(:flight, name: 'B', departs_at: 1.day.from_now)

        booking_alpha = create(:booking, flight: flight_a, created_at: 3.days.ago)
        booking_beta = create(:booking, flight: flight_b, created_at: 2.days.ago)

        get '/api/bookings', headers: valid_headers(admin)
        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].pluck('id')).to eq([booking_alpha.id, booking_beta.id])
      end

      it 'sort by created_at ASC when same departs_at and flight_name' do
        Flight.delete_all
        flight_munich_paris = create(:flight, name: 'Munich-Paris', departs_at: 1.day.from_now)

        booking_alpha = create(:booking, flight: flight_munich_paris, created_at: 3.days.ago)
        booking_beta = create(:booking, flight: flight_munich_paris, created_at: 15.days.ago)

        get '/api/bookings', headers: valid_headers(admin)
        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].pluck('id')).to eq([booking_beta.id, booking_alpha.id])
      end
    end

    context 'when filter is active' do
      around do |example|
        Booking.class_eval do
          def flight_not_in_past; end
        end

        example.run
        Booking.class_eval do
          def flight_not_in_past; end
        end
      end

      it 'returns only bookings with active flights' do
        active_flight = create(:flight, name: 'Active-Flight', departs_at: 2.days.from_now)
        inactive_flight = create(:flight, name: 'New-York-London', departs_at: 3.days.ago)
        booking_active = create(:booking, flight: active_flight, created_at: 1.day.ago)
        create(:booking, flight: inactive_flight, created_at: 2.days.ago)

        get '/api/bookings?filter=active', headers: valid_headers(admin)
        expect(response).to have_http_status(:ok)
        bookings = json_body['bookings']
        booking_ids = bookings.pluck('id')
        expect(bookings.size).to eq(1)
        expect(booking_ids).to contain_exactly(booking_active.id)
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

    it 'returns status 404 if the booking does not exist' do
      get '/api/bookings/999999', headers: valid_headers(admin)
      expect(response).to have_http_status(:not_found)
      expect(json_body).to include('error' => "Couldn't find Booking")
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

    context 'when user_id is invalid' do
      let(:invalid_user_attributes) do
        { booking: { no_of_seats: 2, seat_price: 150, flight_id: flight.id, user_id: 0 } }
      end

      it 'returns 404 not found' do
        post '/api/bookings', params: invalid_user_attributes, headers: valid_headers(admin)
        expect(response).to have_http_status(:not_found)
        expect(json_body).to eq({ 'error' => "Couldn't find User" })
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
