class Trip::Search < Trailblazer::Operation
  step :validate_params
  step :search

  def validate_params(ctx, params:, **)
    missing = [:source, :destination, :date].select { |k| params[k].blank? }
    if missing.any?
      ctx[:errors] = { base: "Missing params: #{missing.join(', ')}" }
      return false
    end
    true
  end

  def search(ctx, params:, **)
    # find all trips where route has stops in source city and destination city
    # and destination stop comes after source stop
    trips = Trip.joins(:route)
                .joins("INNER JOIN route_stops AS boarding_stops
                        ON boarding_stops.route_id = routes.id
                        AND boarding_stops.city_name = '#{params[:source]}'
                        AND boarding_stops.is_boarding_point = true")
                .joins("INNER JOIN route_stops AS drop_stops
                        ON drop_stops.route_id = routes.id
                        AND drop_stops.city_name = '#{params[:destination]}'
                        AND drop_stops.is_drop_point = true")
                .where('drop_stops.km_from_source > boarding_stops.km_from_source')
                .where(status: :scheduled)
                .where(travel_start_date: Date.parse(params[:date]))
                .where('departure_time > ?', Time.current)
                .where('available_seats > 0')
                .includes(:bus, :route, bus: :bus_operator)
                .distinct

    trips = trips.joins(:bus).where(buses: { bus_type: params[:bus_type] }) if params[:bus_type].present?

    ctx[:models] = trips.order(:departure_time)
    true
  end
end