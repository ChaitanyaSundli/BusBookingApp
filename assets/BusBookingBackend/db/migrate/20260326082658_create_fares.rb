class CreateFares < ActiveRecord::Migration[8.1]
  def change
    create_table :fares do |t|
      t.references :route, null: false, foreign_key: true
      t.integer :bus_type
      t.float :base_fare_per_km
      t.float :min_fare
      t.float :tax_pct
      t.float :service_fee

      t.timestamps
    end
  end
end
