module Api
  class SessionsController < Api::BaseController
    before_action :set_serializer
    before_action :authenticate_user!, only: [:destroy]
    skip_before_action :authenticate_user!, only: [:create]

    def create
      user = User.find_by(email: session_params[:email])

      if user&.authenticate(session_params[:password])
        render json: { token: user.token, user: serialize(user, :extended) }, status: :ok
      else
        render json: { errors: { credentials: ['are invalid'] } }, status: :unauthorized
      end
    end

    def destroy
      if current_user
        head :no_content
      else
        render json: { errors: { token: ['is invalid'] } }, status: :unauthorized
      end
    end

    private

    def session_params
      params.require(:session).permit(:email, :password)
    end
  end
end
