class CreateRoutes < ActiveRecord::Migration[8.1]
  def change
    create_table :routes do |t|
      t.string :source_city
      t.string :destination_city
      t.integer :total_distance_km
      t.integer :estimated_duration_mins
      t.boolean :is_active, default: true

      t.timestamps
    end
    add_index :routes, [:source_city, :destination_city]
  end
end
  