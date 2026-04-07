class Trip::Show < Trailblazer::Operation
  step :find_model
  step :authorize

  def find_model(ctx, params:, **)
    ctx[:model] = Trip.includes(:bus, :route, :trip_seats, bus: :bus_operator)
                      .find_by(id: params[:id])
    ctx[:errors] = { trip: 'not found' } and return false unless ctx[:model]
    true
  end

  def authorize(ctx, current_user:, **)
    TripPolicy.new(current_user, ctx[:model]).show?
  end
end