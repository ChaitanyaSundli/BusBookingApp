class Bus::Index < Trailblazer::Operation
  step :authorize
  step :fetch_buses

  def authorize(options, current_user:, bus_operator:, **)
    true 
  end

  def fetch_buses(options, bus_operator:, current_user:, **)
    options[:models] = Pundit.policy_scope(current_user, Bus.where(bus_operator: bus_operator))
  end
end
