class Route::Create < Trailblazer::Operation
  PERMITTED_PARAMS = [:source_city, :destination_city, :total_distance_km,
                      :estimated_duration_mins, :is_active].freeze

  step :build_model
  step :authorize
  step :validate
  step :persist

  def build_model(ctx, **)
    ctx[:model] = Route.new
  end

  def authorize(ctx, current_user:, **)
    RoutePolicy.new(current_user, ctx[:model]).create?
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