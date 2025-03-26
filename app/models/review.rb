class Review < ApplicationRecord
  belongs_to :item
  has_many_attached :images

  validates :username, :title, :score, :description, presence: true
  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
end
