module Api
  class BookingsController < ApplicationController
    before_action :set_booking, only: [:show, :update, :destroy]
    before_action :set_serializer

    def index
      bookings = Booking.all
      render json: { bookings: serialize(bookings, :extended) }
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

    def set_serializer
      @serializer = if action_name == 'show'
                      if request.headers['X-API-SERIALIZER'] == 'fast_jsonapi'
                        FastJsonapi::BookingSerializer
                      else
                        BookingSerializer
                      end
                    else
                      BookingSerializer
                    end
    end

    def serialize(resource, view)
      if @serializer == FastJsonapi::BookingSerializer
        @serializer.new(resource).serializable_hash
      else
        @serializer.render_as_json(resource, view: view)
      end
    end

    def serializer_name
      if @serializer == FastJsonapi::BookingSerializer
        'FastJsonapi'
      else
        'Blueprinter'
      end
    end
  end
end
