class AddPastnotificationsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :pastnotifications, :json, default: []
  end
end
