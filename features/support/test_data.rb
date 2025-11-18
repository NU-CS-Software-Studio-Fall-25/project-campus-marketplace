require "securerandom"

module TestDataHelpers
  def unique_suffix
    SecureRandom.hex(4)
  end

  def default_password
    "Password!1"
  end

  def build_user_attributes(overrides = {})
    suffix = unique_suffix

    {
      first_name: "Test",
      last_name: "User",
      email_address: "student#{suffix}@u.northwestern.edu",
      username: "student#{suffix}",
      phone_number: nil,
      password: default_password,
      password_confirmation: default_password,
      confirmed_at: Time.current
    }.merge(overrides)
  end

  def create_confirmed_user(overrides = {})
    attrs = build_user_attributes(overrides.merge(confirmed_at: Time.current))
    User.create!(attrs).tap do |user|
      @current_user = user
      @current_password = attrs[:password]
    end
  end

  def create_unconfirmed_user(overrides = {})
    attrs = build_user_attributes(overrides.except(:confirmed_at)).merge(confirmed_at: nil)
    User.create!(attrs).tap do |user|
      @current_user = user
      @current_password = attrs[:password]
    end
  end

  def attach_listing_image(listing)
    image_path = Rails.root.join("test/fixtures/files/placeholder.png")
    listing.image.attach(
      io: File.open(image_path),
      filename: "placeholder.png",
      content_type: "image/png"
    )
  end

  def create_listing_for(user, overrides = {})
    attrs = {
      title: "Sample Listing",
      description: "Gently used item available for pickup on campus.",
      price: 25.00,
      category: "other"
    }.merge(overrides)

    listing = user.listings.build(attrs)
    attach_listing_image(listing)
      listing.save!
      listing
    end

  def create_untracked_user(overrides = {})
    User.create!(build_user_attributes(overrides))
  end

  def remember_config(key)
    @config_restores ||= {}
    return if @config_restores.key?(key)

    @config_restores[key] = Rails.application.config.public_send(key)
  end

  def override_config(key, value)
    remember_config(key)
    Rails.application.config.public_send("#{key}=", value)
  end
end

World(TestDataHelpers)
