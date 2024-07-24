module Api
  class CompaniesController < ApplicationController
    before_action :set_company, only: [:show, :update, :destroy]
    before_action :set_serializer

    def index
      companies = Company.all
      if request.headers['X-API-SERIALIZER-ROOT'] == '0'
        render json: serialize(companies, :extended)
      else
        render json: { companies: serialize(companies, :extended) }
      end
    end

    def show
      company = Company.find(params[:id])
      render json: { company: serialize(company, :extended) }
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
      company = Company.find(params[:id])
      if company.update(company_params)
        render json: { company: serialize(company, :extended) }, status: :ok
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    def destroy
      company = Company.find(params[:id])
      company.destroy
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

    def set_serializer
      @serializer = if action_name == 'show'
                      if request.headers['X-API-SERIALIZER'] == 'fast_jsonapi'
                        FastJsonapi::CompanySerializer
                      else
                        CompanySerializer
                      end
                    else
                      CompanySerializer
                    end
    end

    def serialize(resource, view)
      if @serializer == FastJsonapi::CompanySerializer
        @serializer.new(resource).serializable_hash
      else
        @serializer.render_as_json(resource, view: view)
      end
    end

    def serializer_name
      if @serializer == FastJsonapi::CompanySerializer
        'FastJsonapi'
      else
        'Blueprinter'
      end
    end
  end
end
