class Fare::Index < Trailblazer::Operation
  step :find_route
  step :fetch

  def find_route(ctx, params:, **)
    ctx[:route] = Route.find_by(id: params[:route_id])
    ctx[:errors] = { route: 'not found' } and return false unless ctx[:route]
    true
  end

  def fetch(ctx, current_user:, **)
    ctx[:models] = ctx[:route].fares
                              .where(operator_id: current_user.id)
                              .order(created_at: :desc)
    true
  end
end