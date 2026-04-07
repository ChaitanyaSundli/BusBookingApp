class CreateSeats < ActiveRecord::Migration[8.1]
  def change
    create_table :seats do |t|
      t.references :bus, null: false, foreign_key: true
      t.string :seat_number
      t.integer :seat_type
      t.integer :row_number
      t.integer :col_number
      t.integer :deck

      t.timestamps
    end
      add_index :seats, [:bus_id, :seat_number], unique: true
    end
  end
