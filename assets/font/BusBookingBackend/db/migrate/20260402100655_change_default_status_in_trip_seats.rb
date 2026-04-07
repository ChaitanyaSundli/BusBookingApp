class ChangeDefaultStatusInTripSeats < ActiveRecord::Migration[8.1]
  def change
    change_column_default :trip_seats, :status, 0
  end
end