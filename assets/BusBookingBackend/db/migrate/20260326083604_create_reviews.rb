class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :trip, null: false, foreign_key: true
      t.references :bus_operator, foreign_key: true 
      t.integer :rating
      t.text :comment

      t.timestamps
    end
  end
end
