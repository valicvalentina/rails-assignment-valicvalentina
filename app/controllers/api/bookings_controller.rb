module Api
  class BookingsController < Api::BaseController
    before_action :set_booking, only: [:show, :update, :destroy]
    before_action :set_serializer
    before_action :authenticate_user!
    before_action :authorize_user_bookings!, only: [:update, :destroy]
    before_action :authorize_update_user_id, only: [:update]

    def index
      bookings = current_user&.admin? ? Booking.all : current_user.bookings

      if request.headers['X-API-SERIALIZER-ROOT'] == '0'
        render json: serialize(bookings, :extended)
      else
        render json: { bookings: serialize(bookings, :extended) }
      end
    end

    def show
      booking = current_user.admin? ? Booking.find(params[:id]) : find_booking
      if booking
        render json: { booking: serialize(booking, :extended) }
      else
        render json: {
          errors: { resource: ['is forbidden'] }
        }, status: :forbidden
      end
    end

    def create
      booking = current_user.bookings.build(booking_params)
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
    end

    def set_booking
      @booking = Booking.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Couldn't find Booking" }, status: :not_found
    end

    def booking_params
      if current_user.admin?
        params.require(:booking).permit(:flight_id, :no_of_seats, :seat_price, :user_id)
      else
        params.require(:booking).permit(:flight_id, :no_of_seats, :seat_price)
      end
    end
  end
end
