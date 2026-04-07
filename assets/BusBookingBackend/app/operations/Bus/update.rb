class Bus::Update < Trailblazer::Operation
  PERMITTED_PARAMS = [:bus_no, :bus_name, :bus_type, :deck, :is_active]

  step :find_model
  step :authorize_user
  step :assign_attributes
  step :validate_model
  step :persist

  def find_model(ctx, params:, bus_operator:, **)
    ctx[:model] = bus_operator.buses.find_by(id: params[:id])
    if ctx[:model].nil?
      ctx[:model] = Bus.new
      ctx[:model].errors.add(:base, "Bus not found")
      return false
    end
    true
  rescue StandardError => e
    ctx[:model] = Bus.new
    ctx[:model].errors.add(:base, "Error finding bus: #{e.message}")
    false
  end

  def authorize_user(ctx, current_user:, **)
    unless current_user&.operator?
      ctx[:model].errors.add(:base, "Only operators can update buses")
      return false
    end

    unless current_user.bus_operators.exists?(id: ctx[:model].bus_operator_id)
      ctx[:model].errors.add(:base, "You do not have permission to update this bus")
      return false
    end
    true
  end

  def assign_attributes(ctx, params:, **)
    permitted = params[:bus].permit(*PERMITTED_PARAMS)
    ctx[:model].assign_attributes(permitted)
    true
  end

  def validate_model(ctx, **)
    unless ctx[:model].valid?
      return false
    end
    true
  end

  def persist(ctx, **)
    unless ctx[:model].save
      return false
    end
    true
  end
end