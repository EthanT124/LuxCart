# db/migrate/YYYYMMDDHHMMSS_add_rating_columns.rb
class AddRatingColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :rating_distributions, :jsonb, default: {
      "1" => 0,
      "2" => 0,
      "3" => 0,
      "4" => 0,
      "5" => 0
    }
    add_column :items, :average_rating, :decimal, precision: 3, scale: 2, default: 0.0
  end
end
