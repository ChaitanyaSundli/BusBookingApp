class ChangeTripSeatsStatusToInteger < ActiveRecord::Migration[8.1]
  def change
    change_column :trip_seats, :status, :integer, default: 0, null: false
  end
end
