module Api
  module V1
    class BaseController < ApplicationController
      include Pundit::Authorization

      before_action :authenticate_user!

      rescue_from Pundit::NotAuthorizedError do
        render json: { error: 'Forbidden', message: 'You are not authorized' }, status: :forbidden
      end

      rescue_from ActiveRecord::RecordNotFound do |e|
        render json: { error: 'Not Found', message: e.message }, status: :not_found
      end
    end
  end
end