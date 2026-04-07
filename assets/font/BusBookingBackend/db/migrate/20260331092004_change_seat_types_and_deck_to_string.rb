class ChangeSeatTypesAndDeckToString < ActiveRecord::Migration[8.1]
  def change
    change_column :seats, :seat_type, :string, null: true
    
    # Change deck column from integer to string  
    change_column :seats, :deck, :string, null: true
  end
end
