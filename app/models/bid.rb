class Bid < ApplicationRecord
  enum :status, { pending: 0, accepted: 1, rejected: 2, countered: 3 }

  belongs_to :listing
  belongs_to :buyer, class_name: "User"

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :message, profanity: { allow_blank: true }
  validates :response_message, profanity: { allow_blank: true }
  validate :buyer_is_not_owner

  scope :recent_first, -> { order(created_at: :desc) }

  def respond!(new_status:, responder:, response_amount: nil, response_message: nil)
    raise ArgumentError, "Responder must own the listing" unless listing.user == responder

    update!(
      status: new_status,
      response_amount: response_amount,
      response_message: response_message,
      responded_at: Time.current
    )
  end

  private
    def buyer_is_not_owner
      errors.add(:base, "You cannot bid on your own listing.") if listing.present? && listing.user_id == buyer_id
    end
end
