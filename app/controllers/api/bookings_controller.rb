module Api
  class BookingsController < ApplicationController
    before_action :set_booking, only: [:show, :update, :destroy]
    def index
      render json: BookingSerializer.render(Booking.all, view: :extended)
    end

    def show
      booking = Booking.find(params[:id])
      render json: BookingSerializer.render(booking, view: :extended)
    end

    def create
      booking = Booking.new(booking_params)

      if booking.save
        render json: BookingSerializer.render(booking, view: :extended), status: :created
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    def update
      booking = Booking.find(params[:id])
      if booking.update(booking_params)
        render json: BookingSerializer.render(booking, view: :extended), status: :ok
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
      params.require(:booking).permit(:no_of_seats, :seat_price, :user_id, :flight_id)
    end
  end
end
