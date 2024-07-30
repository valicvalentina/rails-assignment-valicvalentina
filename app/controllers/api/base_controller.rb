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
      return if @current_user

      render json: { errors: { token: ['is invalid'] } }, status: :unauthorized
    end

    def session_user
      token = request.headers['Authorization']
      @current_user = User.find_by(token: token)
    end

    def admin?
      current_user&.admin?
    end

    def authorize_admin!
      return if admin?

      render json: {
        errors: { resource: ['is forbidden'] }
      }, status: :forbidden
    end
  end
end
