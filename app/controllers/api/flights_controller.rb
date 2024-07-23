module Api
  class FlightsController < ApplicationController
    before_action :set_flight, only: [:show, :update, :destroy]
    def index
      flights = Flight.all
      render json: { flights: FlightSerializer.render_as_json(flights, view: :extended) }
    end

    def show
      flight = Flight.find(params[:id])
      render json: FlightSerializer.render(flight, view: :extended)
    end

    def create
      flight = Flight.new(flight_params)

      if flight.save
        render json: FlightSerializer.render(flight, view: :extended), status: :created
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    def update
      flight = Flight.find(params[:id])
      if flight.update(flight_params)
        render json: FlightSerializer.render(flight, view: :extended), status: :ok
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    def destroy
      flight = Flight.find(params[:id])
      flight.destroy
      head :no_content
    end

    private

    def set_flight
      @flight = Flight.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Couldn't find Flight" }, status: :not_found
    end

    def flight_params
      params.require(:flight).permit(:name, :no_of_seats, :base_price, :departs_at, :arrives_at,
                                     :company_id)
    end
  end
end
