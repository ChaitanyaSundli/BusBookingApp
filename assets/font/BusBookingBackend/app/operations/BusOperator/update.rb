class BusOperator::Update < Trailblazer::Operation
  PERMITTED_PARAMS = [:company_name, :license_no, :contact_email]

  step :find_model
  step :authorize_user
  step :assign_attributes
  step :validate_model
  step :persist

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
      ctx[:model].errors.add(:base, "You do not have permission to update this operator")
      return false
    end
    true
  end

  def assign_attributes(ctx, params:, **)
    permitted = params[:bus_operator].permit(*PERMITTED_PARAMS)
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
