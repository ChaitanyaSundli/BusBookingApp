class CreateBuses < ActiveRecord::Migration[8.1]
  def change
    create_table :buses do |t|
      t.references :bus_operator, null: false, foreign_key: true
      t.string :bus_no
      t.string :bus_name
      t.string :bus_type
      t.integer :deck
      t.integer :total_seats
      t.boolean :is_active, default: true
      t.timestamps
    end
    add_index :buses, :bus_no, unique: true
  end
end
