# app/models/item.rb

class Item < ApplicationRecord
  serialize :paths, Array, coder: JSON  # Specify coder option as JSON
  has_many_attached :images  # Active Storage association for images
  has_one_attached :video  # Active Storage association for a single video

  def reviews
    # Define how to get reviews for the item
    # For example, if reviews are stored in another table and linked by item_id:
    Review.where(item_id: id)
  end

  def total_reviews
    reviews.count
  end


  validates :title, :description, :cost, :sku, :quantity, :category, :weight, :published, :discount, presence: true, on: :create
end
