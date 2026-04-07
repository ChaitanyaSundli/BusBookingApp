class BusOperator::Index < Trailblazer::Operation
  step :authorize
  step :fetch_bus_operators

  def authorize(options, current_user:, **)
    true 
  end

  def fetch_bus_operators(options, current_user:, **)
    options[:models] = Pundit.policy_scope(current_user, BusOperator)
  end
end
