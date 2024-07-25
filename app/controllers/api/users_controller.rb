module Api
  class UsersController < Api::BaseController
    before_action :set_user, only: [:show, :update, :destroy]
    before_action :set_serializer

    def index
      users = User.all
      if request.headers['X-API-SERIALIZER-ROOT'] == '0'
        render json: serialize(users, :extended)
      else
        render json: { users: serialize(users, :extended) }
      end
    end

    def show
      user = User.find(params[:id])
      render json: { user: serialize(user, :extended) }
    end

    def create
      user = User.new(user_params)
      if user.save
        render json: { user: serialize(user, :extended) }, status: :created
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    def update
      user = User.find(params[:id])
      if user.update(user_params)
        render json: { user: serialize(user, :extended) }, status: :ok
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    def destroy
      user = User.find(params[:id])
      user.destroy
      head :no_content
    end

    private

    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Couldn't find User" }, status: :not_found
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email)
    end
  end
end
