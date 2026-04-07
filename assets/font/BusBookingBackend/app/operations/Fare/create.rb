class Fare::Create < Trailblazer::Operation
  PERMITTED_PARAMS = [:bus_type, :base_fare_per_km, :min_fare,
                      :tax_pct, :service_fee].freeze

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

  def build_model(ctx, current_user:, **)
    ctx[:model]             = Fare.new
    ctx[:model].route       = ctx[:route]
    ctx[:model].operator_id = current_user.id
    true
  end

  def authorize(ctx, current_user:, **)
    FarePolicy.new(current_user, ctx[:model]).create?
  end

  def validate(ctx, params:, **)
    permitted    = params[:fare].permit(*PERMITTED_PARAMS)
    clean_params = permitted.to_h.reject { |_, v| v.nil? || v == '' }
    ctx[:model].assign_attributes(clean_params)
    ctx[:model].valid?
  end

  def persist(ctx, **)
    ctx[:model].save
  end
end