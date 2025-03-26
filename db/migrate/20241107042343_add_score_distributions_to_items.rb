class AddScoreDistributionsToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :score_distributions, :jsonb, default: {
      "1": 0,
      "2": 0,
      "3": 0,
      "4": 0,
      "5": 0
    }
  end
end
