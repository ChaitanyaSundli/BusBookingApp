class Trip::Index < Trailblazer::Operation
  step :fetch

  def fetch(ctx, current_user:, params:, **)
    trips = TripPolicy::Scope.new(current_user, Trip).resolve
                             .includes(:bus, :route, bus: :bus_operator)
                             .order(departure_time: :asc)

    trips = trips.where(status: params[:status]) if params[:status].present?

    ctx[:models] = trips
    true
  end
end