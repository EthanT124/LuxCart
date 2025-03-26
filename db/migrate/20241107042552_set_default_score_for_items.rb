class SetDefaultScoreForItems < ActiveRecord::Migration[7.0]
  def up
    # First destroy all reviews
    Review.destroy_all

    # Add average_score column if it doesn't exist
    unless column_exists?(:items, :average_score)
      add_column :items, :average_score, :decimal, precision: 3, scale: 2, default: 0.0
    end

    # Add score_distributions column if it doesn't exist
    unless column_exists?(:items, :score_distributions)
      add_column :items, :score_distributions, :jsonb, default: {
        "1": 0,
        "2": 0,
        "3": 0,
        "4": 0,
        "5": 0
      }
    end

    # Update all existing items
    Item.update_all(
      average_score: 0.0,
      score_distributions: {
        "1": 0,
        "2": 0,
        "3": 0,
        "4": 0,
        "5": 0
      }
    )
  end

  def down
    remove_column :items, :average_score
    remove_column :items, :score_distributions
  end
end
