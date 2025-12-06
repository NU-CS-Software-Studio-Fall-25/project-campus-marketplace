class Listing < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  has_many :favorites, dependent: :destroy
  has_many :favorited_by, through: :favorites, source: :user
  has_many :bids, dependent: :destroy
  has_many :hidden_listings, dependent: :destroy

  enum :category, {
    electronics: "electronics",
    clothing: "clothing",
    furniture: "furniture",
    other: "other"
  }

  validates :title, presence: true, length: { maximum: 50 }
  validates :description, presence: true, length: { maximum: 1000 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10000000 }
  validates :category, inclusion: { in: categories.keys }
  validate :image_requirements

  private
    def image_requirements
      unless image.attached?
        errors.add(:image, "must be attached")
        return
      end

      unless image.content_type.in?(%w[ image/png image/jpeg image/jpg ])
        errors.add(:image, "must be a JPEG or PNG")
      end

      if image.byte_size > 5.megabytes
        errors.add(:image, "must be smaller than 5MB")
      end
    end
end
