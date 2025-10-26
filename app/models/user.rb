class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :listings, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :username, with: ->(name) { name.strip.downcase }
  normalizes :phone_number, with: ->(phone) { phone.strip }

  EMAIL_DOMAIN_REGEX = /\A[^@\s]+@u\.northwestern\.edu\z/i
  PHONE_REGEX = /\A\+?\d{10,15}\z/

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }, format: { with: EMAIL_DOMAIN_REGEX, message: "must end with u.northwestern.edu" }
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validates :phone_number, allow_blank: true, format: { with: PHONE_REGEX, message: "must be digits with optional leading +" }
end
