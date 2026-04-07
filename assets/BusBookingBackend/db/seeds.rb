require 'securerandom'

puts "🌱 Seeding..."

# ================= CLEAN =================
[BookingSeat, Payment, Review, Booking, TripSeat, Trip, Seat,
 Fare, RouteStop, Route, Bus, BusOperator, Passenger, User].each(&:delete_all)

# ================= CONSTANTS =================
BUS_TYPES = %w[ac_seater non_ac_seater ac_sleeper non_ac_sleeper].freeze

CITIES = %w[
  Ahmedabad Pune Mumbai Delhi Jaipur Indore Bhopal Surat
  Lucknow Kanpur Nagpur Hyderabad Bangalore
]

# ================= USERS =================
puts "👤 Users..."

operator_users = 10.times.map do |i|
  User.create!(
    name: "Operator #{i+1}",
    email: "operator#{i+1}@test.com",
    phone: "98#{format('%08d', i)}",
    password: "password",
    role: "operator"
  )
end

customer_users = 20.times.map do |i|
  User.create!(
    name: "Customer #{i+1}",
    email: "customer#{i+1}@test.com",
    phone: "97#{format('%08d', i)}",
    password: "password",
    role: "passenger"
  )
end

# ================= OPERATORS =================
puts "🚍 Operators..."

bus_operators = operator_users.map do |u|
  BusOperator.create!(
    user: u,
    company_name: "#{u.name} Travels",
    license_no: SecureRandom.hex(4),
    contact_email: u.email,
    is_verified: true
  )
end

# ================= ROUTES =================
puts "🛣️ Routes..."

routes = []

20.times do
  source = CITIES.sample
  destination = (CITIES - [source]).sample

  route = Route.create!(
    source_city: source,
    destination_city: destination,
    total_distance_km: rand(300..1200),
    estimated_duration_mins: rand(300..900)
  )

  stops = [source, *CITIES.sample(2), destination]

  stops.each_with_index do |city, i|
    RouteStop.create!(
      route: route,
      city_name: city,
      stop_name: "#{city} Bus Stand",
      stop_address: "#{city} Main Road",
      stop_order: i + 1,
      km_from_source: (route.total_distance_km * i / (stops.size - 1)),
      is_boarding_point: i == 0,
      is_drop_point: i == stops.size - 1
    )
  end

  routes << route
end

# ================= BUSES =================
puts "🚌 Buses..."

buses = []

bus_operators.each do |op|
  2.times do
    bus = Bus.create!(
      bus_operator: op,
      bus_name: "Bus #{SecureRandom.hex(2)}",
      bus_no: SecureRandom.hex(3).upcase,
      bus_type: BUS_TYPES.sample,   # ✅ string enum
      total_seats: 40,
      deck: 1
    )

    40.times do |i|
      Seat.create!(
        bus: bus,
        seat_number: "S#{i+1}",
        seat_type: ["window", "aisle"][i % 2],
        row_number: (i / 4) + 1,
        col_number: (i % 4) + 1,
        deck: "L"
      )
    end

    buses << bus
  end
end

# ================= FARES =================
puts "💰 Fares..."

routes.each do |route|
  bus_operators.each do |op|
    BUS_TYPES.each do |type|
      Fare.create!(
        route_id: route.id,
        operator_id: op.id,
        bus_type: type,   # ✅ string
        base_fare_per_km: rand(1.5..3.0),
        min_fare: rand(150..300),
        service_fee: rand(30..80),
        tax_pct: 5
      )
    end
  end
end

# ================= TRIPS =================
puts "🗓️ Trips..."

trips = []

10.times do |day|
  date = Date.current + day

  buses.each_with_index do |bus, i|
    route = routes[i % routes.length]

    departure_time = Time.zone.parse("#{date} 05:00") + (i * 20).minutes
    arrival_time = departure_time + route.estimated_duration_mins.minutes

    trip = Trip.create!(
      bus: bus,
      route: route,
      travel_start_date: date,
      departure_time: departure_time,
      arrival_time: arrival_time,
      available_seats: bus.total_seats,
      status: :scheduled   # ✅ enum symbol (important)
    )

    trips << trip
  end
end


# ================= UPDATE SEATS =================
trips.each do |trip|
  trip.update!(
    available_seats: trip.trip_seats.where(status: "available").count
  )
end

puts "🎉 SEED DONE SUCCESSFULLY!"