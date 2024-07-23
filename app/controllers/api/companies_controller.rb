module Api
  class CompaniesController < ApplicationController
    before_action :set_company, only: [:show, :update, :destroy]

    def index
      render json: CompanySerializer.render(Company.all, view: :extended)
    end

    def show
      company = Company.find(params[:id])
      render json: CompanySerializer.render(company, view: :extended)
    end

    def create
      company = Company.new(company_params)

      if company.save
        render json: CompanySerializer.render(company, view: :extended), status: :created
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    def update
      company = Company.find(params[:id])
      if company.update(company_params)
        render json: CompanySerializer.render(company, view: :extended), status: :ok
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
  end
end
