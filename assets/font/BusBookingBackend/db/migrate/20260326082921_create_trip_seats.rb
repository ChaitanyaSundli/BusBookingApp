class CreateTripSeats < ActiveRecord::Migration[8.1]
  def change
    create_table :trip_seats do |t|
      t.references :trip, null: false, foreign_key: true
      t.references :seat, null: false, foreign_key: true
      t.float :seat_price
      t.string     :status,   null: false, default: 'available'    
        t.integer :locked_by_user
      t.datetime :lock_expiry_time

      t.timestamps
    end
    add_index :trip_seats, [:trip_id, :seat_id], unique: true
    add_index :trip_seats, :status
    add_index :trip_seats, :locked_by_user
  end 
end
