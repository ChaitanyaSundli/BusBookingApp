class CreatePassengers < ActiveRecord::Migration[8.1]
  def change
    create_table :passengers do |t|
      t.string :name, null: false
      t.integer :age, null:false
      t.string :phone
      t.integer :gender, null: false

      t.timestamps
    end
  end
end
