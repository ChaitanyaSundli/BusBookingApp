module Payments
  class Create < Trailblazer::Operation
    step :find_booking
    step :create_payment
    step :process_payment
    fail :release_seats_on_failure
    fail :collect_errors

    def find_booking(ctx, params:, current_user:, **)
      booking = current_user.bookings.find_by(id: params[:booking_id])
      return false unless booking   
      ctx[:booking] = booking
   end


    def create_payment(ctx, booking:, **)
      ctx[:payment] = Payment.create!(
        booking: booking,
        amount: booking.total_price,
        status: :pending
      )
    end

    def process_payment(ctx, payment:, booking:, **)
      payment.update!(status: :success)
      booking.update!(status: :confirmed)
      booking.trip_seats.update_all(
        status: 2,
        locked_by_user: nil,
        lock_expiry_time: nil
      )
    rescue
      payment.update!(status: :failed)
      booking.update!(status: :failed)
      false
    end

    def release_seats_on_failure(ctx, booking:, **)
      booking.trip_seats.update_all(
        status: 0,
        locked_by_user: nil,
        lock_expiry_time: nil
      )
    end

    def collect_errors(ctx, error:, **)
      ctx[:errors] = Array(error)
    end
  end
end
