# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

return unless Rails.env.development?

sample_users = [
  {
    first_name: "Alex",
    last_name: "Johnson",
    email_address: "alex@u.northwestern.edu",
    username: "alex",
    phone_number: "8475550101",
    password: "password123",
    listings: [
      {
        title: "Dorm Mini Fridge",
        description: "Lightly used mini fridge in great condition. Perfect for dorm rooms.",
        price: 65
      },
      {
        title: "Calculus Textbook",
        description: "Latest edition, no markings. Used for Math 230 last quarter.",
        price: 40
      }
    ]
  },
  {
    first_name: "Jamie",
    last_name: "Chen",
    email_address: "jamie@u.northwestern.edu",
    username: "jamie",
    phone_number: "3125550199",
    password: "password123",
    listings: [
      {
        title: "Bike with Lock",
        description: "Hybrid bike plus U-lock. Ideal for commuting around campus.",
        price: 120
      },
      {
        title: "Dorm Lamp",
        description: "LED desk lamp with adjustable brightness settings.",
        price: 25
      }
    ]
  },
  {
    first_name: "Riley",
    last_name: "Garcia",
    email_address: "riley@u.northwestern.edu",
    username: "riley",
    password: "password123",
    listings: [
      {
        title: "Gently Used iPad",
        description: "iPad Air 64GB, includes case and charger.",
        price: 250
      },
      {
        title: "NU Hoodie",
        description: "Official Northwestern hoodie, size M, barely worn.",
        price: 30
      }
    ]
  }
]

ActiveRecord::Base.transaction do
  sample_users.each do |attributes|
    listings = attributes.delete(:listings) || []
    password = attributes.delete(:password)
    identifier_email = attributes[:email_address]
    identifier_username = attributes[:username]

    user = User.find_by(email_address: identifier_email) || User.find_by(username: identifier_username) || User.new
    user.assign_attributes(attributes)
    user.password = password
    user.save!

    listings.each do |listing_attributes|
      listing = user.listings.find_or_initialize_by(title: listing_attributes.fetch(:title))
      listing.assign_attributes(listing_attributes)
      listing.save!
    end
  end
end
