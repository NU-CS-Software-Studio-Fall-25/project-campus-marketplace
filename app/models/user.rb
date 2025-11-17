require "securerandom"

class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :listings, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :liked_listings, through: :favorites, source: :listing

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :username, with: ->(name) { name.strip.downcase }
  normalizes :phone_number, with: ->(phone) { phone.strip }
  normalizes :first_name, with: ->(name) { name&.squish }
  normalizes :last_name, with: ->(name) { name&.squish }

EMAIL_DOMAIN_REGEX = /\A[^@\s]+@(u\.)?northwestern\.edu\z/i
PHONE_REGEX = /\A\+?\d{10,15}\z/
PASSWORD_RESET_TOKEN_VALID_FOR = 30.minutes
CONFIRMATION_TOKEN_VALID_FOR = 2.days

  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }, format: { with: EMAIL_DOMAIN_REGEX, message: "must end with northwestern.edu or u.northwestern.edu" }
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validates :phone_number, allow_blank: true, format: { with: PHONE_REGEX, message: "must be digits with optional leading +" }
  validates :google_uid, uniqueness: true, allow_nil: true

  def full_name
    [ first_name, last_name ].select(&:present?).join(" ")
  end

  def liked?(listing)
    favorites.exists?(listing_id: listing.id)
  end

  def confirmed?
    confirmed_at.present?
  end

  def pending_confirmation?
    !confirmed?
  end

  def generate_confirmation_token!
    raw_token = SecureRandom.urlsafe_base64(32)

    update!(
      confirmation_token_digest: BCrypt::Password.create(raw_token),
      confirmation_sent_at: Time.current
    )

    raw_token
  end

  def valid_confirmation_token?(token)
    return false if confirmation_token_digest.blank? || token.blank?

    BCrypt::Password.new(confirmation_token_digest).is_password?(token)
  rescue BCrypt::Errors::InvalidHash
    false
  end

  def confirmation_token_expired?
    confirmation_sent_at.blank? || confirmation_sent_at < CONFIRMATION_TOKEN_VALID_FOR.ago
  end

  def confirm!
    update!(confirmed_at: Time.current, confirmation_token_digest: nil, confirmation_sent_at: nil)
  end

  def generate_password_reset!
    raw_token = SecureRandom.urlsafe_base64(32)

    update!(
      reset_password_digest: BCrypt::Password.create(raw_token),
      reset_password_sent_at: Time.current
    )

    raw_token
  end

  def valid_password_reset_token?(token)
    return false if reset_password_digest.blank? || token.blank?

    BCrypt::Password.new(reset_password_digest).is_password?(token)
  rescue BCrypt::Errors::InvalidHash
    false
  end

  def password_reset_expired?
    reset_password_sent_at.blank? || reset_password_sent_at < PASSWORD_RESET_TOKEN_VALID_FOR.ago
  end

  def clear_password_reset!
    update_columns(reset_password_digest: nil, reset_password_sent_at: nil)
  end

  def self.from_google(auth)
    raise ArgumentError, "auth hash missing" if auth.blank?

    info = auth.respond_to?(:info) ? auth.info : auth["info"]
    credentials = auth.respond_to?(:credentials) ? auth.credentials : auth["credentials"]
    email = info&.email || info&.[]("email")
    raise ArgumentError, "Google account must provide an email address" if email.blank?

    normalized_email = email.strip.downcase
    uid = auth.respond_to?(:uid) ? auth.uid : auth["uid"]

    user = find_by(google_uid: uid) || find_by(email_address: normalized_email)

    attributes = {
      google_uid: uid,
      google_token: credentials&.token || credentials&.[]("token")
    }

    refresh_token = credentials&.refresh_token || credentials&.[]("refresh_token")
    attributes[:google_refresh_token] = refresh_token if refresh_token.present?

    expires_at = credentials&.expires_at || credentials&.[]("expires_at")
    attributes[:google_token_expires_at] = Time.zone.at(expires_at) if expires_at.present?

    if user
      attributes[:confirmed_at] = Time.current if user.confirmed_at.blank?
      user.update!(attributes.compact)
      user
    else
      first_name = info&.first_name || info&.[]("first_name")
      last_name = info&.last_name || info&.[]("last_name")

      if first_name.blank? && last_name.blank?
        name_parts = (info&.name || info&.[]("name")).to_s.split(" ")
        first_name = name_parts.first.presence || "Student"
        last_name = name_parts[1..]&.join(" ").presence || "User"
      end

      username = generate_unique_username(normalized_email.split("@").first)
      random_password = SecureRandom.hex(32)

      create!(
        email_address: normalized_email,
        password: random_password,
        username: username,
        first_name: first_name || "Student",
        last_name: last_name || "User",
        confirmed_at: Time.current,
        **attributes.compact
      )
    end
  end

  def self.generate_unique_username(base)
    slug = base.to_s.downcase.gsub(/[^a-z0-9]/, "")
    slug = "student" if slug.blank?
    slug = slug[0, 20]
    candidate = slug
    suffix = 1

    while exists?(username: candidate)
      candidate = "#{slug}#{suffix}"
      suffix += 1
    end

    candidate
  end
end
