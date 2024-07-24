module Api
  class FlightsController < ApplicationController
    before_action :set_flight, only: [:show, :update, :destroy]
    before_action :set_serializer

    def index
      flights = Flight.all
      render json: { flights: serialize(flights, :extended) }
    end

    def show
      flight = Flight.find(params[:id])
      render json: { flight: serialize(flight, :extended) }
    end

    def create
      flight = Flight.new(flight_params)
      if flight.save
        render json: { flight: serialize(flight, :extended) }, status: :created
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    def update
      flight = Flight.find(params[:id])
      if flight.update(flight_params)
        render json: { flight: serialize(flight, :extended) }, status: :ok
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

    def set_serializer
      @serializer = case request.headers['X-API-SERIALIZER']
                    when 'fast_jsonapi'
                      FastJsonapi::FlightSerializer
                    else
                      FlightSerializer
                    end
    end

    def serialize(resource, view)
      if @serializer == FastJsonapi::FlightSerializer
        @serializer.new(resource).serializable_hash
      else
        @serializer.render_as_json(resource, view: view)
      end
    end

    def serializer_name
      if @serializer == FastJsonapi::FlightSerializer
        'FastJsonapi'
      else
        'Blueprinter'
      end
    end
  end
end
