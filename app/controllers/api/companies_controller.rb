module Api
  class CompaniesController < Api::BaseController
    before_action :set_company, only: [:show, :update, :destroy]
    before_action :set_serializer
    before_action :session_user
    before_action :authenticate_user!, except: [:index, :show]
    before_action :authorize_admin!, except: [:index, :show]

    def index
      companies = Company.all
      if request.headers['X-API-SERIALIZER-ROOT'] == '0'
        render json: serialize(companies, :extended)
      else
        render json: { companies: serialize(companies, :extended) }
      end
    end

    def show
      render json: { company: serialize(@company, :extended) }
    end

    def create
      company = Company.new(company_params)
      if company.save
        render json: { company: serialize(company, :extended) }, status: :created
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    def update
      if @company.update(company_params)
        render json: { company: serialize(@company, :extended) }, status: :ok
      else
        render json: { errors: @company.errors }, status: :bad_request
      end
    end

    def destroy
      @company.destroy
      head :no_content
    end

    private

    def set_company
      @company = Company.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Couldn't find Company" }, status: :not_found
    end

    def company_params
      params.require(:company).permit(:name)
    end
  end
end
