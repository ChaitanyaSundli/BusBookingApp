class Bus::AllForOperator < Trailblazer::Operation
  step :authorize_user
  step :fetch_buses

  def authorize_user(ctx, current_user:, **)
    unless current_user&.operator?
      ctx[:errors] = "Only operators can view their buses"
      return false
    end
    true
  end

  def fetch_buses(ctx, current_user:, **)
    operator_ids = BusOperator.where(user_id: current_user.id).pluck(:id)
    ctx[:models] = Bus.where(bus_operator_id: operator_ids).includes(:bus_operator)
    true
  end
end
