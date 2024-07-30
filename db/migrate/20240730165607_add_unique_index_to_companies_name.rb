class AddUniqueIndexToCompaniesName < ActiveRecord::Migration[6.1]
  def change
    add_index :companies, :name, unique: true, name: 'index_companies_on_normal_name'
  end
end
