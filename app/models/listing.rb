class Listing < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates :title, presence: true, length: { maximum: 50 }
  validates :description, presence: true, length: { maximum: 1000 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :image_presence

  private
    def image_presence
      errors.add(:image, "must be attached") unless image.attached?
    end
end
