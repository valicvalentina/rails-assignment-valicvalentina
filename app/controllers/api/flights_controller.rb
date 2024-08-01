module Api
  class FlightsController < Api::BaseController
    before_action :set_flight, only: [:show, :update, :destroy]
    before_action :set_serializer
    before_action :session_user
    before_action :authenticate_user!, except: [:index, :show]
    before_action :authorize_admin!, except: [:index, :show]

    def index
      flights = Flight.includes(:company, :bookings).active.sorted
      flights = filter_flights_by_params(flights)
      if request.headers['X-API-SERIALIZER-ROOT'] == '0'
        render json: serialize(flights, :extended)
      else
        render json: { flights: serialize(flights, :extended) }
      end
    end

    def show
      render json: { flight: serialize(@flight, :extended) }
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
      if @flight.update(flight_params)
        render json: { flight: serialize(@flight, :extended) }, status: :ok
      else
        render json: { errors: @flight.errors }, status: :bad_request
      end
    end

    def destroy
      @flight.destroy
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

    # dodaj filtriranje u zasebnu klasu
    def filter_flights_by_params(flights)
      flights = filter_by_name(flights) if params[:name_cont].present?
      flights = filter_by_departure_time(flights) if params[:departs_at_eq].present?
      if params[:no_of_available_seats_gteq].present?
        flights = filter_by_min_available_seats(flights)
      end
      flights
    end

    def filter_by_name(flights)
      flights.by_name(params[:name_cont])
    end

    def filter_by_departure_time(flights)
      flights.by_departure_time(params[:departs_at_eq])
    end

    def filter_by_min_available_seats(flights)
      flights.by_min_available_seats(params[:no_of_available_seats_gteq])
    end
  end
end
