# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_02_034142) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "booking_seats", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.datetime "created_at", null: false
    t.bigint "passenger_id", null: false
    t.float "seat_price"
    t.bigint "trip_seat_id", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id", "trip_seat_id"], name: "index_booking_seats_on_booking_id_and_trip_seat_id", unique: true
    t.index ["booking_id"], name: "index_booking_seats_on_booking_id"
    t.index ["passenger_id"], name: "index_booking_seats_on_passenger_id"
    t.index ["trip_seat_id"], name: "index_booking_seats_on_trip_seat_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "boarding_stop_id"
    t.datetime "created_at", null: false
    t.bigint "drop_stop_id"
    t.integer "status", default: 0
    t.float "total_price"
    t.bigint "trip_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["boarding_stop_id"], name: "index_bookings_on_boarding_stop_id"
    t.index ["drop_stop_id"], name: "index_bookings_on_drop_stop_id"
    t.index ["trip_id"], name: "index_bookings_on_trip_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "bus_operators", force: :cascade do |t|
    t.string "company_name"
    t.string "contact_email"
    t.datetime "created_at", null: false
    t.boolean "is_verified", default: false
    t.string "license_no"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.datetime "verified_at"
    t.index ["user_id"], name: "index_bus_operators_on_user_id"
  end

  create_table "buses", force: :cascade do |t|
    t.string "bus_name"
    t.string "bus_no"
    t.bigint "bus_operator_id", null: false
    t.integer "bus_type"
    t.datetime "created_at", null: false
    t.integer "deck", default: 1, null: false
    t.boolean "is_active", default: true
    t.integer "total_seats"
    t.datetime "updated_at", null: false
    t.index ["bus_operator_id"], name: "index_buses_on_bus_operator_id"
  end

  create_table "fares", force: :cascade do |t|
    t.float "base_fare_per_km"
    t.integer "bus_type"
    t.datetime "created_at", null: false
    t.float "min_fare"
    t.bigint "operator_id"
    t.bigint "route_id", null: false
    t.float "service_fee"
    t.float "tax_pct"
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_fares_on_route_id"
  end

  create_table "passengers", force: :cascade do |t|
    t.integer "age"
    t.datetime "created_at", null: false
    t.integer "gender"
    t.string "name"
    t.string "phone"
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.float "amount"
    t.bigint "booking_id", null: false
    t.datetime "created_at", null: false
    t.string "gateway_name"
    t.string "gateway_txn_id"
    t.datetime "paid_at"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_payments_on_booking_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "bus_operator_id"
    t.text "comment"
    t.datetime "created_at", null: false
    t.integer "rating"
    t.bigint "trip_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["bus_operator_id"], name: "index_reviews_on_bus_operator_id"
    t.index ["trip_id"], name: "index_reviews_on_trip_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "route_stops", force: :cascade do |t|
    t.string "city_name"
    t.datetime "created_at", null: false
    t.integer "halt_mins"
    t.boolean "is_boarding_point", default: true
    t.boolean "is_drop_point", default: true
    t.integer "km_from_source"
    t.bigint "route_id", null: false
    t.time "scheduled_arrival_time"
    t.time "scheduled_departure_time"
    t.string "stop_address"
    t.string "stop_name"
    t.integer "stop_order"
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_route_stops_on_route_id"
  end

  create_table "routes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "destination_city"
    t.integer "estimated_duration_mins"
    t.boolean "is_active", default: true
    t.string "source_city"
    t.integer "total_distance_km"
    t.datetime "updated_at", null: false
  end

  create_table "seats", force: :cascade do |t|
    t.bigint "bus_id", null: false
    t.integer "col_number"
    t.datetime "created_at", null: false
    t.string "deck"
    t.integer "row_number"
    t.string "seat_number"
    t.string "seat_type"
    t.datetime "updated_at", null: false
    t.index ["bus_id"], name: "index_seats_on_bus_id"
  end

  create_table "trip_seats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "lock_expiry_time"
    t.integer "locked_by_user"
    t.bigint "seat_id", null: false
    t.float "seat_price"
    t.integer "status"
    t.bigint "trip_id", null: false
    t.datetime "updated_at", null: false
    t.index ["seat_id"], name: "index_trip_seats_on_seat_id"
    t.index ["trip_id"], name: "index_trip_seats_on_trip_id"
  end

  create_table "trips", force: :cascade do |t|
    t.datetime "arrival_time"
    t.integer "available_seats"
    t.bigint "bus_id", null: false
    t.datetime "created_at", null: false
    t.datetime "departure_time"
    t.bigint "route_id", null: false
    t.integer "status", default: 0
    t.date "travel_start_date"
    t.datetime "updated_at", null: false
    t.index ["bus_id"], name: "index_trips_on_bus_id"
    t.index ["route_id"], name: "index_trips_on_route_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "dob"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.boolean "is_active", default: true
    t.string "name", null: false
    t.string "phone", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "booking_seats", "bookings"
  add_foreign_key "booking_seats", "passengers"
  add_foreign_key "booking_seats", "trip_seats"
  add_foreign_key "bookings", "route_stops", column: "boarding_stop_id"
  add_foreign_key "bookings", "route_stops", column: "drop_stop_id"
  add_foreign_key "bookings", "trips"
  add_foreign_key "bookings", "users"
  add_foreign_key "bus_operators", "users"
  add_foreign_key "buses", "bus_operators"
  add_foreign_key "fares", "routes"
  add_foreign_key "payments", "bookings"
  add_foreign_key "reviews", "bus_operators"
  add_foreign_key "reviews", "trips"
  add_foreign_key "reviews", "users"
  add_foreign_key "route_stops", "routes"
  add_foreign_key "seats", "buses"
  add_foreign_key "trip_seats", "seats"
  add_foreign_key "trip_seats", "trips"
  add_foreign_key "trips", "buses"
  add_foreign_key "trips", "routes"
end
