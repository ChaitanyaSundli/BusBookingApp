class Route::Update < Trailblazer::Operation
  PERMITTED_PARAMS = [:source_city, :destination_city, :total_distance_km,
                      :estimated_duration_mins, :is_active].freeze

  step :find_model
  step :authorize
  step :validate
  step :persist

  def find_model(ctx, params:, **)
    ctx[:model] = Route.find_by(id: params[:id])
    ctx[:errors] = { route: 'not found' } and return false unless ctx[:model]
    true
  end

  def authorize(ctx, current_user:, **)
    RoutePolicy.new(current_user, ctx[:model]).update?
  end

  def validate(ctx, params:, **)
    permitted    = params[:route].permit(*PERMITTED_PARAMS)
    clean_params = permitted.to_h.reject { |_, v| v.nil? || v == '' }
    ctx[:model].assign_attributes(clean_params)
    ctx[:model].valid?
  end

  def persist(ctx, **)
    ctx[:model].save
  end
end