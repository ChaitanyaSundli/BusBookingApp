module Api
  module V1
    module Auth
      class OperatorRegistrationsController < ApplicationController
        def create
          user = User.new(user_params)
          user.role = 'operator'

          if user.save
            token = user.generate_jwt
            render json: {
              message: 'Operator registered successfully',
              token: token,
              user: {
                id:    user.id,
                name:  user.name,
                email: user.email,
                role:  user.role
              }
            }, status: :created
          else
            render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def user_params
          params.require(:user).permit(:name, :email, :phone, :password, :dob)
        end
      end
    end
  end
end