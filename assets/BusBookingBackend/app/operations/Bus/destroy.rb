class Bus::Destroy < Trailblazer::Operation
  step :find_model
  step :authorize_user
  step :destroy

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
      ctx[:model].errors.add(:base, "Only operators can delete buses")
      return false
    end

    unless current_user.bus_operators.exists?(id: ctx[:model].bus_operator_id)
      ctx[:model].errors.add(:base, "You do not have permission to delete this bus")
      return false
    end
    true
  end

  def destroy(ctx, **)
    if ctx[:model].destroy
      true
    else
      ctx[:model].errors.add(:base, "Failed to delete bus")
      false
    end
  end
end
