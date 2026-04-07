class RouteStop::Create < Trailblazer::Operation
  PERMITTED_PARAMS = [:city_name, :stop_name, :stop_address, :stop_order,
                      :km_from_source, :scheduled_arrival_time,
                      :scheduled_departure_time, :halt_mins,
                      :is_boarding_point, :is_drop_point].freeze

  step :find_route
  step :build_model
  step :authorize
  step :validate
  step :persist

  def find_route(ctx, params:, **)
    ctx[:route] = Route.find_by(id: params[:route_id])
    ctx[:errors] = { route: 'not found' } and return false unless ctx[:route]
    true
  end

  def build_model(ctx, **)
    ctx[:model] = RouteStop.new
    ctx[:model].route = ctx[:route]
    true
  end

  def authorize(ctx, current_user:, **)
    RouteStopPolicy.new(current_user, ctx[:model]).create?
  end

  def validate(ctx, params:, **)
    permitted    = params[:route_stop].permit(*PERMITTED_PARAMS)
    clean_params = permitted.to_h.reject { |_, v| v.nil? || v == '' }
    ctx[:model].assign_attributes(clean_params)
    ctx[:model].valid?
  end

  def persist(ctx, **)
    ctx[:model].save
  end
end