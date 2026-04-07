class CreateRouteStops < ActiveRecord::Migration[8.1]
  def change
    create_table :route_stops do |t|
      t.references :route, null: false, foreign_key: true
      t.string :city_name
      t.string :stop_name
      t.text :stop_address
      t.integer :stop_order
      t.integer :km_from_source
      t.time :scheduled_arrival_time
      t.time :scheduled_departure_time
      t.integer :halt_mins
      t.boolean :is_boarding_point, default: true
      t.boolean :is_drop_point, default: true

      t.timestamps
    end
        add_index :route_stops, [:route_id, :stop_order]
  end
end
