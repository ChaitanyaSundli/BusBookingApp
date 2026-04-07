class Booking::Create < Trailblazer::Operation
  step :find_trip
  step :lock_seats
  step :calculate_total
  step :create_booking
  step :create_booking_seats
  step :create_payment
  fail :release_locks_on_failure
  fail :collect_errors

  def find_trip(ctx, params:, **)
    ctx[:trip] = Trip.find_by(id: params[:trip_id])
    ctx[:trip].present?
  end

  def lock_seats(ctx, params:, trip:, current_user:, **)
    requested = trip.trip_seats.where(id: params[:seat_ids])
    available_requested = requested.available

    if available_requested.count == params[:seat_ids].count
      available_requested.update_all(
        status: 1,
        locked_by_user: current_user.id,
        lock_expiry_time: 15.minutes.from_now
      )
      ctx[:locked_seats] = trip.trip_seats.where(id: params[:seat_ids]).to_a
      true
    else
      unavailable_ids = requested.where.not(id: available_requested.map(&:id)).pluck(:id)
      ctx[:error] = "Seats #{unavailable_ids.join(', ')} are already taken or locked"
      false
    end
  end

  def calculate_total(ctx, trip:, params:, locked_seats:, **)
    boarding = RouteStop.find(params[:boarding_stop_id])
    drop     = RouteStop.find(params[:drop_stop_id])
    distance = (drop.km_from_source - boarding.km_from_source).abs

    total = locked_seats.sum { |seat| seat.seat_price }
    ctx[:total_price] = total
    true
  end

  def create_booking(ctx, current_user:, trip:, params:, total_price:, **)
    ctx[:booking] = Booking.create!(
      user: current_user,
      trip: trip,
      boarding_stop_id: params[:boarding_stop_id],
      drop_stop_id: params[:drop_stop_id],
      total_price: total_price,
      status: :pending
    )
    true
  rescue => e
    ctx[:error] = e.message
    false
  end

  def create_booking_seats(ctx, booking:, locked_seats:, params:, **)
    passengers = params[:passengers] || []
    passengers.zip(locked_seats).each do |passenger_params, trip_seat|
      passenger = Passenger.create!(passenger_params)
      BookingSeat.create!(
        booking: booking,
        trip_seat: trip_seat,
        passenger: passenger,
        seat_price: trip_seat.seat_price
      )
    end
    true
  rescue => e
    ctx[:error] = e.message
    false
  end

  def create_payment(ctx, booking:, total_price:, **)
    ctx[:payment] = Payment.create!(
      booking: booking,
      amount: total_price,
      status: :pending
    )
    true
  rescue => e
    ctx[:error] = e.message
    false
  end

  def release_locks_on_failure(ctx, trip:, current_user:, **)
    trip.trip_seats.where(locked_by_user: current_user.id, status: 1).update_all(
      status: 0,
      locked_by_user: nil,
      lock_expiry_time: nil 
    )
  end

  def collect_errors(ctx, error:, **)
    ctx[:errors] = Array(error)
  end
end
