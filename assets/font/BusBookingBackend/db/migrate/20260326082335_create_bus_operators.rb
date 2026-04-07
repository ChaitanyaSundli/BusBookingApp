class CreateBusOperators < ActiveRecord::Migration[8.1]
  def change
    create_table :bus_operators do |t|
      t.references :user, null: false, foreign_key: true
      t.string :company_name
      t.string :license_no
      t.string :contact_email
      t.boolean :is_verified, default: false
      t.datetime :verified_at

      t.timestamps
    end
    add_index :bus_operators, :user_id,    unique: true
  end
end
