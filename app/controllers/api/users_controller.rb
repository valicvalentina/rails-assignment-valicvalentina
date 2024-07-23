module Api
  class UsersController < ApplicationController
    before_action :set_user, only: [:show, :update, :destroy]

    def index
      users = User.all
      render json: { users: UserSerializer.render_as_json(users, view: :extended) }
    end

    def show
      user = User.find(params[:id])
      render json: { user: UserSerializer.render_as_json(user, view: :extended) }
    end

    def create
      user = User.new(user_params)
      if user.save
        render json: { user: UserSerializer.render_as_json(user, view: :extended) },
               status: :created
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    def update
      user = User.find(params[:id])
      if user.update(user_params)
        render json: { user: UserSerializer.render_as_json(user, view: :extended) }, status: :ok
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
      params.require(:user).permit(:first_name, :email)
    end
  end
end
