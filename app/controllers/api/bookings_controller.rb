module Api
  class BookingsController < Api::BaseController
    before_action :set_booking, only: [:show, :update, :destroy]
    before_action :set_serializer

    def index
      bookings = Booking.all
      if request.headers['X-API-SERIALIZER-ROOT'] == '0'
        render json: serialize(bookings, :extended)
      else
        render json: { bookings: serialize(bookings, :extended) }
      end
    end

    def show
      booking = Booking.find(params[:id])
      render json: { booking: serialize(booking, :extended) }
    end

    def create
      booking = Booking.new(booking_params)
      if booking.save
        render json: { booking: serialize(booking, :extended) }, status: :created
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    def update
      booking = Booking.find(params[:id])
      if booking.update(booking_params)
        render json: { booking: serialize(booking, :extended) }, status: :ok
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    def destroy
      booking = Booking.find(params[:id])
      booking.destroy
      head :no_content
    end

    private

    def set_booking
      @booking = Booking.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Couldn't find Booking" }, status: :not_found
    end

    def booking_params
      params.require(:booking).permit(:flight_id, :user_id, :no_of_seats, :seat_price)
    end
  end
end
