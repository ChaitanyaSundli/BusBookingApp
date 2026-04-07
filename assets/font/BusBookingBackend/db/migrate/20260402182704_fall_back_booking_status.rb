class FallBackBookingStatus < ActiveRecord::Migration[8.1]
 def up
    # Replace all NULLs with 0 (pending)
    execute <<-SQL
      UPDATE bookings SET status = '0' WHERE status IS NULL;
    SQL
  end

  def down
    # Optional rollback
    execute <<-SQL
      UPDATE bookings SET status = NULL WHERE status = '0';
    SQL
  end
end
