module Api
  class BaseController < ApplicationController
    attr_reader :current_user

    def set_serializer
      if action_name == 'show' && request.headers['X-API-SERIALIZER'] == 'fast_jsonapi'
        return @serializer = "FastJsonapi::#{serializer_name}".constantize
      end

      @serializer = serializer_name
    end

    def serialize(resource, view)
      if @serializer == "FastJsonapi::#{serializer_name}".constantize
        @serializer.new(resource).serializable_hash
      else
        @serializer.render_as_json(resource, view: view)
      end
    end

    def serializer_name
      if controller_name == 'sessions'
        UserSerializer
      else
        "#{controller_name.capitalize.singularize}Serializer".constantize
      end
    end

    private

    def authenticate_user!
      token = request.headers['Authorization']
      @current_user = User.find_by(token: token)

      return if @current_user

      render json: { errors: { token: ['is invalid'] } }, status: :unauthorized
    end

    def authorize_admin!
      token = request.headers['Authorization']
      @current_user = User.find_by(token: token)
      return if current_user&.admin?

      render json: {
        errors: { resource: ['is forbidden'] }
      }, status: :forbidden
    end

    def authorize_user_users!
      token = request.headers['Authorization']
      @current_user = User.find_by(token: token)
      user = User.find(params[:id])
      return if current_user.admin? || current_user == user

      render json: { errors: { resource: ['is forbidden'] } },
             status: :forbidden
    end

    def authorize_update_role
      token = request.headers['Authorization']
      @current_user = User.find_by(token: token)
      return unless params[:user]&.key?(:role) && !current_user.admin?

      render json: { errors: { message: 'Only administrators can update the role attribute' } },
             status: :forbidden
    end

    def authorize_update_user_id
      token = request.headers['Authorization']
      @current_user = User.find_by(token: token)
      return unless params[:booking]&.key?(:user_id) && !current_user.admin?

      render json: { errors: { message: 'Only administrators can update the role attribute' } },
             status: :forbidden
    end

    def authorize_user_bookings!
      token = request.headers['Authorization']
      @current_user = User.find_by(token: token)
      @booking = Booking.find(params[:id])
      return if current_user.admin? || current_user == @booking.user

      render json: { errors: { resource: ['is forbidden'] } },
             status: :forbidden
    end
  end
end
