class Api::V1::PaymentsController < ApplicationController
  before_action :authenticate_user!

  def create
    result = ::Payments::Create.call(params: payment_params, current_user: current_user)
    if result.success?
      render json: {
        payment_id: result[:payment].id,
        status: result[:payment].status,
        booking_status: result[:booking].status
      }, status: :ok
    else 
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end  

  private
  def payment_params
    params.permit(:booking_id)
  end
end
