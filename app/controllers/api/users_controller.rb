module Api
  class UsersController < ApplicationController
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

    def set_serializer
      @serializer = if action_name == 'show'
                      if request.headers['X-API-SERIALIZER'] == 'fast_jsonapi'
                        FastJsonapi::UserSerializer
                      else
                        UserSerializer
                      end
                    else
                      UserSerializer
                    end
    end

    def serialize(resource, view)
      if @serializer == FastJsonapi::UserSerializer
        @serializer.new(resource).serializable_hash
      else
        @serializer.render_as_json(resource, view: view)
      end
    end

    def serializer_name
      if @serializer == FastJsonapi::UserSerializer
        'FastJsonapi'
      else
        'Blueprinter'
      end
    end
  end
end
