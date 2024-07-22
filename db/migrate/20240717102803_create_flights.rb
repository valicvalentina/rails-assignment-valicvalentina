class CreateFlights < ActiveRecord::Migration[6.1]
  def change
    create_table :flights do |t|
      t.string :name, null: false
      t.integer :no_of_seats
      t.decimal :base_price, precision: 10, scale: 2, null: false
      t.datetime :departs_at, null: false
      t.datetime :arrives_at, null: false
      t.belongs_to :company, index: true, foreign_key: true

      t.timestamps
    end
    add_index :flights, [:name, :company_id], unique: true
  end
end
