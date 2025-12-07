class Report < ApplicationRecord
  enum :status, { open: 0, reviewed: 1, closed: 2 }

  belongs_to :listing
  belongs_to :reporter, class_name: "User"

  validates :reason, presence: true, length: { maximum: 255 }
  validates :details, length: { maximum: 2000 }, allow_blank: true
  validates :listing_id, uniqueness: { scope: :reporter_id, message: "already reported by you" }
end
