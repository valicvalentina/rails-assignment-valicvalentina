module Api
  class BookingsController < Api::BaseController
    before_action :set_booking, only: [:show, :update, :destroy]
    before_action :set_serializer
    before_action :session_user
    before_action :authenticate_user!
    before_action :authorize_user_bookings!, only: [:update, :destroy]
    before_action :authorize_update_user_id, only: [:update]

    def index
      bookings = admin? ? Booking.includes(:flight, :user) : current_user.bookings

      bookings = bookings.with_active_flights if params[:filter] == 'active'
      bookings = bookings.ordered_by_flight_details

      if request.headers['X-API-SERIALIZER-ROOT'] == '0'
        render json: serialize(bookings, :extended)
      else
        render json: { bookings: serialize(bookings, :extended) }
      end
    end

    def show
      booking = admin? ? @booking : find_booking
      if booking
        render json: { booking: serialize(booking, :extended) }
      else
        render json: {
          errors: { resource: ['is forbidden'] }
        }, status: :forbidden
      end
    end

    def create
      booking = build_booking
      return if performed?

      if booking.save
        render json: { booking: serialize(booking, :extended) }, status: :created
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    def update
      if @booking
        if @booking.update(booking_params)
          render json: { booking: serialize(@booking, :extended) }, status: :ok
        else
          render json: { errors: @booking.errors }, status: :bad_request
        end
      else
        render json: { errors: { booking: ['not found'] } }, status: :not_found
      end
    end

    def destroy
      if @booking
        @booking.destroy
        head :no_content
      else
        render json: { errors: { booking: ['not found'] } }, status: :not_found
      end
    end

    private

    def find_booking
      current_user.bookings.find_by(id: params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Couldn't find Booking" }, status: :not_found
    end

    def set_booking
      @booking = Booking.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Couldn't find Booking" }, status: :not_found
    end

    def booking_params
      if admin?
        params.require(:booking).permit(:flight_id, :no_of_seats, :seat_price, :user_id)
      else
        params.require(:booking).permit(:flight_id, :no_of_seats, :seat_price)
      end
    end

    def authorize_update_user_id
      return unless params[:booking]&.key?(:user_id) && !admin?

      render json: { errors: { message: 'Only administrators can update the role attribute' } },
             status: :forbidden
    end

    def authorize_user_bookings!
      return if admin? || current_user == @booking.user

      render json: { errors: { resource: ['is forbidden'] } },
             status: :forbidden
    end

    def build_booking
      if current_user.admin? && booking_params[:user_id]
        user = User.find_by(id: booking_params[:user_id])
        if user
          user.bookings.build(booking_params.except(:user_id))
        else
          render json: { error: "Couldn't find User" }, status: :not_found
        end
      else
        current_user.bookings.build(booking_params)
      end
    end
  end
end
