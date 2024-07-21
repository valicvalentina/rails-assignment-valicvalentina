class CreateCompanies < ActiveRecord::Migration[6.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false, index: { unique: true }
      t.timestamps
    end
    add_index :companies, 'LOWER(name)', unique: true
  end
end
