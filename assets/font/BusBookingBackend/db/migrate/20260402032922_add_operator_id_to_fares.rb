class AddOperatorIdToFares < ActiveRecord::Migration[8.1]
  def change
    add_column :fares, :operator_id, :bigint
  end
end
