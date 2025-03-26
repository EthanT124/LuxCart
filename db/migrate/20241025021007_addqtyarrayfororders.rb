class Addqtyarrayfororders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :qty, :json, default: []
  end
end
