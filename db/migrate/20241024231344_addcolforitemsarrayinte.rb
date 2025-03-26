class Addcolforitemsarrayinte < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :items, :json, default: []
  end
end
