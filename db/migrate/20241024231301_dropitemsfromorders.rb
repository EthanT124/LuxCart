class Dropitemsfromorders < ActiveRecord::Migration[7.1]
  def change
    remove_column :orders, :items, :integer
  end
end
