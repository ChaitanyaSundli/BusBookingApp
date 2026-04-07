class AddDeckToBuses < ActiveRecord::Migration[8.1]
  def change
    add_column :buses, :deck, :integer, default: 1, null: false
  end
end
