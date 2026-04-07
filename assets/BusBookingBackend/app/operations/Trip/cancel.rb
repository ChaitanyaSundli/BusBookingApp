class Trip::Cancel < Trailblazer::Operation
  step :find_model
  step :authorize
  step :validate_cancellable
  step :cancel

  def find_model(ctx, params:, **)
    ctx[:model] = Trip.find_by(id: params[:id])
    ctx[:errors] = { trip: 'not found' } and return false unless ctx[:model]
    true
  end

  def authorize(ctx, current_user:, **)
    TripPolicy.new(current_user, ctx[:model]).cancel?
  end

  def validate_cancellable(ctx, **)
    unless ctx[:model].scheduled?
      ctx[:errors] = { trip: 'only scheduled trips can be cancelled' }
      return false
    end
    if ctx[:model].departure_time < 2.hours.from_now
      ctx[:errors] = { trip: 'cannot cancel trip within 2 hours of departure' }
      return false
    end
    true
  end

  def cancel(ctx, **)
    ctx[:model].cancelled!
  end
end