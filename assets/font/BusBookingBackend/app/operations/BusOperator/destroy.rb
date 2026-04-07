class BusOperator::Destroy < Trailblazer::Operation
  step :find_model
  step :authorize_user
  step :destroy

  def find_model(ctx, params:, **)
    ctx[:model] = BusOperator.find_by(id: params[:id])
    if ctx[:model].nil?
      ctx[:model] = BusOperator.new
      ctx[:model].errors.add(:base, "Bus operator not found")
      return false
    end
    true
  rescue StandardError => e
    ctx[:model] = BusOperator.new
    ctx[:model].errors.add(:base, "Error finding operator: #{e.message}")
    false
  end

  def authorize_user(ctx, current_user:, **)
    unless current_user&.id == ctx[:model].user_id || current_user&.admin?
      ctx[:model].errors.add(:base, "You do not have permission to delete this operator")
      return false
    end
    true
  end

  def destroy(ctx, **)
    if ctx[:model].destroy
      true
    else
      ctx[:model].errors.add(:base, "Failed to delete bus operator")
      false
    end
  end
end
