class AddDefaultStatusToTrips < ActiveRecord::Migration[8.1]
  def change
    change_column_default :trips, :status, from: nil, to: 0
  end
end