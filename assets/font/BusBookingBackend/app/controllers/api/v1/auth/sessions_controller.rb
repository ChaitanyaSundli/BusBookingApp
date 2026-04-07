module Api
  module V1
    module Auth
      class SessionsController < BaseController
        skip_before_action :authenticate_user!, only: [:create]

        def create
          email = params[:email] || params.dig(:user, :email)
          password = params[:password] || params.dig(:user, :password)

          user = User.find_by(email: email)

          if user&.valid_password?(password)
            token = user.generate_jwt

            render json: {
              message: 'User logged in successfully',
              token: token,
              user: {
                id:    user.id,
                name:  user.name,
                email: user.email,
                role:  user.role
              }
            }, status: :ok
          else
            render json: { error: 'Invalid email or password' }, status: :unauthorized
          end
        end

        def destroy
          render json: { message: 'User logged out successfully' }, status: :ok
        end
      end
    end
  end
end