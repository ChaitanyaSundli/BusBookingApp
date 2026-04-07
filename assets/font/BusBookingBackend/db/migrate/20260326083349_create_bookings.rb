class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :trip, null: false, foreign_key: true
      t.references :boarding_stop, foreign_key: { to_table: :route_stops }
      t.references :drop_stop, foreign_key: { to_table: :route_stops }
      t.float :total_price
      t.string :status, null: false, default: "pending"

      t.timestamps
    end  
      add_index :bookings, :status
  end
end
