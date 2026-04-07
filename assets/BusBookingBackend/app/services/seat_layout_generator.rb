class SeatLayoutGenerator
  SEAT_LAYOUTS = {
    ac_seater: { rows: 10, cols: 3 },
    non_ac_seater: { rows: 10, cols: 3 },
    ac_sleeper: { rows: 5, cols: 3 },
    non_ac_sleeper: { rows: 5, cols: 3 }
  }.freeze

  COL_CONFIGURATIONS = {
    seater: [
      { col: 1, seat_type: :single },
      { col: 2, seat_type: :aisle },
      { col: 3, seat_type: :window }
    ],
    sleeper: [
      { col: 1, seat_type: :single },
      { col: 2, seat_type: :aisle },
      { col: 3, seat_type: :sleeper }
    ]
  }.freeze

  def self.generate_for_bus(bus)
    new(bus).generate
  end

  def initialize(bus)
    @bus = bus
    bus_type_sym = bus.bus_type&.to_s&.downcase&.to_sym
    @layout = SEAT_LAYOUTS[bus_type_sym]
  end

  def generate
    unless @layout
      Rails.logger.warn "Invalid bus type: #{@bus.bus_type}"
      return { seats: [], total_seats: 0 }
    end

    seats_data = []
    decks = @bus.deck&.to_i || 1
    rows = @layout[:rows]
    bus_type_sym = @bus.bus_type.to_s.downcase.to_sym

    bus_category = bus_type_sym.to_s.include?('sleeper') ? :sleeper : :seater
    col_config = COL_CONFIGURATIONS[bus_category]

    (1..decks).each do |deck_num|
      deck = deck_num == 1 ? :lower : :upper

      (1..rows).each do |row_num|
        col_config.each do |col_config_item|
          seat_type = get_seat_type(col_config_item[:seat_type])
          seat_number = generate_seat_number(row_num, col_config_item[:col], deck_num)

          seats_data << {
            bus_id: @bus.id,
            seat_number: seat_number,
            row_number: row_num,
            col_number: col_config_item[:col],
            seat_type: seat_type.to_s,
            deck: deck.to_s,
            created_at: Time.current,
            updated_at: Time.current
          }
        end
      end
    end

    Seat.insert_all(seats_data) if seats_data.any?

    { seats: seats_data, total_seats: seats_data.length }
  end

  def self.get_layout(bus_type, deck_count = 1)
    return default_layout if bus_type.blank?

    bus_type_sym = bus_type.to_s.downcase.to_sym
    layout = SEAT_LAYOUTS[bus_type_sym]

    unless layout
      Rails.logger.warn "Invalid bus type: #{bus_type}"
      return default_layout
    end

    total_seats = layout[:rows] * layout[:cols] * deck_count

    bus_category = bus_type.to_s.include?('sleeper') ? :sleeper : :seater
    col_config = COL_CONFIGURATIONS[bus_category]

    {
      bus_type: bus_type,
      rows: layout[:rows],
      cols: layout[:cols],
      decks: deck_count,
      seats_per_deck: layout[:rows] * layout[:cols],
      total_seats: total_seats,
      layout: col_config,
      description: seat_layout_description(layout, deck_count)
    }
  end

  def self.default_layout
    {
      bus_type: "unknown",
      rows: 0,
      cols: 0,
      decks: 1,
      seats_per_deck: 0,
      total_seats: 0,
      layout: [],
      description: "Invalid bus type"
    }
  end

  private

  def get_seat_type(col_type)
    case col_type
    when :window
      :window
    when :aisle
      :aisle
    when :sleeper
      :sleeper
    when :single
      :single
    else
      :window
    end
  end

  def generate_seat_number(row, col, deck)
    deck_prefix = deck == 1 ? 'L' : 'U'
    "#{deck_prefix}#{row}#{col}"
  end

  def self.seat_layout_description(layout, deck_count)
    total = layout[:rows] * layout[:cols] * deck_count
    "#{layout[:rows]} rows × 3 columns × #{deck_count} deck(s) = #{total} seats"
  end

  def self.available_seat_types
    ['window', 'aisle', 'sleeper', 'single']
  end

  def self.seat_type_description(seat_type)
    descriptions = {
      'window' => 'Window seat',
      'aisle' => 'Aisle seat',
      'sleeper' => 'Sleeper seat',
      'single' => 'Single seat'
    }
    descriptions[seat_type] || 'Unknown seat type'
  end
end