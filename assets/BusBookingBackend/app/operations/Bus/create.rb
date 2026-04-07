class Bus::Create < Trailblazer::Operation
  PERMITTED_PARAMS = [:bus_no, :bus_name, :bus_type, :deck].freeze

  step :build_model
  step :assign_bus_operator
  step :authorize_user
  step :assign_attributes
  step :calculate_total_seats
  step :validate_model
  step :persist
  step :generate_seats

  def build_model(ctx, **)
    ctx[:model] = Bus.new
    true
  end

  def assign_bus_operator(ctx, bus_operator:, **)
    unless bus_operator.present?
      ctx[:model].errors.add(:base, "Bus operator not found")
      return false
    end
    ctx[:model].bus_operator = bus_operator
    true
  end

  def authorize_user(ctx, current_user:, bus_operator:, **)
    unless current_user&.operator?
      ctx[:model].errors.add(:base, "Only operators can create buses")
      return false
    end

    unless current_user.bus_operators.exists?(id: bus_operator.id)
      ctx[:model].errors.add(:base, "You do not have permission to add buses to this operator")
      return false
    end
    true
  end

  def assign_attributes(ctx, params:, **)
    begin
      permitted = params.dig(:bus)&.permit(*PERMITTED_PARAMS) || {}
      clean_params = permitted.to_h.reject { |_, v| v.nil? || v.to_s.empty? }
      clean_params['deck'] = (clean_params['deck'] || 1).to_i
      ctx[:model].assign_attributes(clean_params)
      true
    rescue StandardError => e
      ctx[:model].errors.add(:base, "Parameter processing error: #{e.message}")
      false
    end
  end

  def calculate_total_seats(ctx, **)
    bus_type = ctx[:model].bus_type&.to_sym
    deck_count = ctx[:model].deck&.to_i || 1

    layout = SeatLayoutGenerator::SEAT_LAYOUTS[bus_type]
    if layout
      cols = layout[:cols]
      rows = layout[:rows]
      ctx[:model].total_seats = rows * cols * deck_count
    else
      ctx[:model].errors.add(:bus_type, "is invalid")
      return false
    end
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

  def generate_seats(ctx, **)
    if ctx[:model].persisted?
      begin
        SeatLayoutGenerator.generate_for_bus(ctx[:model])
      rescue StandardError => e
        ctx[:model].errors.add(:base, "Failed to generate seats: #{e.message}")
        return false
      end
    end
    true
  end
end