class RouteStop::Index < Trailblazer::Operation
  step :find_route
  step :fetch

  def find_route(ctx, params:, **)
    ctx[:route] = Route.find_by(id: params[:route_id])
    ctx[:errors] = { route: 'not found' } and return false unless ctx[:route]
    true
  end

  def fetch(ctx, params:, **)
    stops = ctx[:route].route_stops.ordered
    # find by city
    stops = stops.where(city_name: params[:city]) if params[:city].present?
    # filter by boarding and dfrop points
    stops = stops.boarding_points if params[:boarding].present?
    stops = stops.drop_points     if params[:drop].present?
    ctx[:models] = stops
    true
  end
end