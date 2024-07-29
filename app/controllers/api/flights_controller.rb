module Api
  class FlightsController < Api::BaseController
    before_action :set_flight, only: [:show, :update, :destroy]
    before_action :set_serializer
    before_action :session_user
    before_action :authenticate_user!, except: [:index, :show]
    before_action :authorize_admin!, except: [:index, :show]

    def index
      flights = Flight.all
      if request.headers['X-API-SERIALIZER-ROOT'] == '0'
        render json: serialize(flights, :extended)
      else
        render json: { flights: serialize(flights, :extended) }
      end
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
  end
end
