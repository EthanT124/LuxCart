class DropOrderItemsTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :order_items
  end
end
