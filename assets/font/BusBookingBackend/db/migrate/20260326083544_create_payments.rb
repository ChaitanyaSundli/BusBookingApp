class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :booking, null: false, foreign_key: true
      t.float :amount
      t.integer :status
      t.string :gateway_txn_id
      t.string :gateway_name
      t.datetime :paid_at

      t.timestamps
    end
  end
end
