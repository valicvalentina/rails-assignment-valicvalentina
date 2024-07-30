class AddTokenToUsers < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :token, :string
    add_index :users, :token, unique: true

    User.reset_column_information
    User.find_each do |user|
      user.update_column(:token, SecureRandom.hex(10))
    end
  end

  def down
    remove_index :users, :token
    remove_column :users, :token
  end
end
