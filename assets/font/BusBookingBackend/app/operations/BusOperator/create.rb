class BusOperator::Create < Trailblazer::Operation
  PERMITTED_PARAMS = [:company_name, :license_no, :contact_email]

  step :build_model
  step :authorize_user
  step :assign_user
  step :assign_attributes
  step :validate_model
  step :persist

  def build_model(ctx, **)
    ctx[:model] = BusOperator.new
    true
  end

  def authorize_user(ctx, current_user:, **)
    unless current_user&.operator?
      ctx[:model].errors.add(:base, "Only operators can create bus operator accounts")
      return false
    end
    true
  end

  def assign_user(ctx, current_user:, **)
    ctx[:model].user = current_user
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
