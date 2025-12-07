class Listing < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  has_many :favorites, dependent: :destroy
  has_many :favorited_by, through: :favorites, source: :user
  has_many :bids, dependent: :destroy
  has_many :hidden_listings, dependent: :destroy
  has_many :reports, dependent: :destroy

  enum :category, {
    electronics: "electronics",
    clothing: "clothing",
    furniture: "furniture",
    other: "other"
  }

  validates :title, presence: true, length: { maximum: 50 }, profanity: true
  validates :description, presence: true, length: { maximum: 1000 }, profanity: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10000000 }
  validates :category, inclusion: { in: categories.keys }
  validate :image_requirements
  validate :content_safety_check

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

    def content_safety_check
      # Only run safety check if content safety is enabled
      return unless Rails.application.config.respond_to?(:content_safety_enabled) &&
                    Rails.application.config.content_safety_enabled

      # Skip check if listing is not new and hasn't changed
      return unless new_record? || title_changed? || description_changed? || image.attached?

      safety_service = ContentSafetyService.new(self)
      result = safety_service.check_safety

      unless result[:safe]
        errors.add(:base, "This listing cannot be published: #{result[:reason]}. " \
                          "Please ensure your listing does not contain prohibited items " \
                          "(drugs, alcohol, weapons, etc.)")
      end
    end
end
