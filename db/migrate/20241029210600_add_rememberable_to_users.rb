# db/migrate/xxxxxx_add_rememberable_to_users.rb
class AddRememberableToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :remember_created_at, :datetime
  end
end
