class Api::V1::BookingsController < ApplicationController
  before_action :authenticate_user!

  def create
    result = Booking::Create.call(params: booking_params, current_user: current_user)
    puts"==========================="
    if result.success?
      render json: {
        booking_id: result[:booking].id,
        seats: result[:locked_seats].map(&:seat_id),
        total_price: result[:total_price],
        payment_id: result[:payment].id,
        status: result[:booking].status
      }, status: :ok
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  def index
    bookings = current_user.bookings.includes(:trip, :booking_seats)
    render json: bookings
  end

  def show
    booking = current_user.bookings.find(params[:id])
    render json: booking
  end

  def cancel
    booking = current_user.bookings.find(params[:id])
    authorize booking, :cancel?
    booking.update!(status: "cancelled")
    booking.trip_seats.update_all(status: "available", locked_by_user: nil, lock_expiry_time: nil)
    booking.payments.last.update!(status: "refunded")
    render json: { status: "cancelled" }
  end

  private

  def booking_params
    params.permit(:trip_id, :boarding_stop_id, :drop_stop_id, seat_ids: [], passengers: [:name, :age, :gender])
  end
end
