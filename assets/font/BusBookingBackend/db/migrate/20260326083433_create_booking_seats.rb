class CreateBookingSeats < ActiveRecord::Migration[8.1]
  def change
    create_table :booking_seats do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :trip_seat, null: false, foreign_key: true
      t.references :passenger, null: false, foreign_key: true
      t.float :seat_price

      t.timestamps
    end
      add_index :booking_seats, [:booking_id, :trip_seat_id], unique: true
  end
end
