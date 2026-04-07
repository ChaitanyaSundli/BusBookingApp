class ChangeBookingsStatusToInteger < ActiveRecord::Migration[8.1]
  def change
    change_column :bookings, :status, :integer, default: 0, null: false, using: 'status::integer'
  end
end
