class CreateTrips < ActiveRecord::Migration[8.1]
  def change
    create_table :trips do |t|
      t.references :bus, null: false, foreign_key: true
      t.references :route, null: false, foreign_key: true
      t.date :travel_start_date
      t.datetime :departure_time
      t.datetime :arrival_time
      t.string :status, null: false,  default: "scheduled"
      t.integer :available_seats
      t.timestamps
    end
     add_index :trips, [:bus_id, :travel_start_date, :route_id], unique: true
     add_index :trips, :status
  end
end
