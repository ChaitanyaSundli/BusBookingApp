class Trip::Create < Trailblazer::Operation
  PERMITTED_PARAMS = [:bus_id, :route_id, :travel_start_date,
                      :departure_time, :arrival_time].freeze

  step :build_model
  step :authorize
  step :validate
  step :persist

  def build_model(ctx, **)
    ctx[:model] = Trip.new
    true
  end

  def authorize(ctx, current_user:, **)
    TripPolicy.new(current_user, ctx[:model]).create?
  end

  def validate(ctx, params:, current_user:, **)
    permitted    = params[:trip].permit(*PERMITTED_PARAMS)
    clean_params = permitted.to_h.reject { |_, v| v.nil? || v == '' }
    ctx[:model].assign_attributes(clean_params)

    if ctx[:model].bus.present?
      unless ctx[:model].bus.bus_operator_id == current_user.bus_operators&.first&.id
        ctx[:errors] = { bus: 'does not belong to your company' }
        return false
      end
    end

    ctx[:model].valid?
  end

  def persist(ctx, **)
    ctx[:model].save
  end
end