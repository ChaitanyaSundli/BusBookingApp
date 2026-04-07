class Route::Show < Trailblazer::Operation
  step :find_model
  step :authorize

  def find_model(ctx, params:, **)
    ctx[:model] = Route.includes(:route_stops, :fares).find_by(id: params[:id])
    ctx[:errors] = { route: 'not found' } and return false unless ctx[:model]
    true  
end

  def authorize(ctx, current_user:, **)
    RoutePolicy.new(current_user, ctx[:model]).show?
  end
end