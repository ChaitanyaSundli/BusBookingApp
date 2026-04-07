class Bus::Show < Trailblazer::Operation
  step :find_model
  step :authorize_user

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
    true
  end
end
