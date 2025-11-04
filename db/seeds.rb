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

generated_listings = [
  { title: "NU Wildcats Hoodie", description: "Perfect for dorms Lightweight and portable Includes accessories.", price: 22.57 },
  { title: "Organic Chemistry Textbook", description: "Great condition Lightweight and portable Gently worn.", price: 35.85 },
  { title: "Desk Organizer Set", description: "Great condition Barely used Barely used.", price: 91.79 },
  { title: "Dorm Room Microwave", description: "Gently worn Must pick up on campus Barely used.", price: 90.93 },
  { title: "Graphing Calculator", description: "Lightweight and portable Perfect for dorms Lightweight and portable.", price: 10.4 },
  { title: "Biology Lab Kit", description: "Gently worn Helps with classes Perfect for dorms.", price: 26.77 },
  { title: "Noise Cancelling Headphones", description: "Perfect for dorms Barely used Barely used.", price: 227.3 },
  { title: "Gently Used Laptop", description: "Great condition Includes accessories Lightweight and portable.", price: 199.62 },
  { title: "Dorm Futon", description: "Includes accessories Helps with classes Great condition.", price: 147.62 },
  { title: "Portable Heater", description: "Gently worn Helps with classes Must pick up on campus.", price: 194.51 },
  { title: "Rolling Backpack", description: "Gently worn Great condition Lightweight and portable.", price: 207.11 },
  { title: "Standing Desk Converter", description: "Lightweight and portable Helps with classes Lightweight and portable.", price: 224.31 },
  { title: "Marketing 201 Notes", description: "Great condition Barely used Perfect for dorms.", price: 99.89 },
  { title: "Dorm Plants Bundle", description: "Includes accessories Barely used Gently worn.", price: 229.28 },
  { title: "AirPods Pro (2nd Gen)", description: "Lightweight and portable Perfect for dorms Helps with classes.", price: 90.86 },
  { title: "Portable Projector", description: "Gently worn Great condition Must pick up on campus.", price: 103.04 },
  { title: "Dorm Room Coffee Maker", description: "Gently worn Great condition Gently worn.", price: 150.69 },
  { title: "Bluetooth Speaker", description: "Lightweight and portable Great condition Includes accessories.", price: 249.41 },
  { title: "Dress Shoes Size 10", description: "Must pick up on campus Helps with classes Barely used.", price: 248.03 },
  { title: "LED Strip Lights", description: "Helps with classes Lightweight and portable Helps with classes.", price: 46.9 },
  { title: "Smartwatch", description: "Barely used Helps with classes Must pick up on campus.", price: 20.59 },
  { title: "Electric Kettle", description: "Gently worn Includes accessories Lightweight and portable.", price: 15.04 },
  { title: "Dorm Storage Bins", description: "Great condition Perfect for dorms Perfect for dorms.", price: 162.22 },
  { title: "Weighted Blanket", description: "Perfect for dorms Perfect for dorms Lightweight and portable.", price: 132.48 },
  { title: "Fitness Tracker", description: "Lightweight and portable Perfect for dorms Lightweight and portable.", price: 225.4 },
  { title: "Spanish 101 Workbook", description: "Gently worn Includes accessories Helps with classes.", price: 16.99 },
  { title: "Mechanical Keyboard", description: "Gently worn Lightweight and portable Gently worn.", price: 17.93 },
  { title: "Dorm Area Rug", description: "Barely used Lightweight and portable Perfect for dorms.", price: 15.71 },
  { title: "Reusable Water Bottles", description: "Barely used Gently worn Must pick up on campus.", price: 182.25 },
  { title: "Professional Suit Jacket", description: "Great condition Lightweight and portable Includes accessories.", price: 188.59 },
  { title: "Dorm Curtain Set", description: "Includes accessories Lightweight and portable Gently worn.", price: 45.07 },
  { title: "Yoga Mat", description: "Gently worn Perfect for dorms Barely used.", price: 40.35 },
  { title: "Chemistry Lab Coat", description: "Lightweight and portable Lightweight and portable Great condition.", price: 202.55 },
  { title: "Calculus Study Guide", description: "Helps with classes Great condition Gently worn.", price: 187.93 },
  { title: "Monitor Stand", description: "Helps with classes Includes accessories Lightweight and portable.", price: 117.93 },
  { title: "Dorm Room Fan", description: "Great condition Barely used Gently worn.", price: 199.87 },
  { title: "Printer with Ink", description: "Barely used Gently worn Perfect for dorms.", price: 219.13 },
  { title: "Wireless Mouse", description: "Gently worn Must pick up on campus Gently worn.", price: 140.91 },
  { title: "Desk Lamp with USB Ports", description: "Must pick up on campus Must pick up on campus Gently worn.", price: 32.29 },
  { title: "Smart TV 32 inch", description: "Great condition Perfect for dorms Must pick up on campus.", price: 73.49 },
  { title: "Dorm Bedding Set", description: "Great condition Must pick up on campus Includes accessories.", price: 131.23 },
  { title: "Cookware Starter Kit", description: "Perfect for dorms Gently worn Perfect for dorms.", price: 145.51 },
  { title: "Dorm Laundry Hamper", description: "Barely used Barely used Helps with classes.", price: 91.87 },
  { title: "Portable Hard Drive", description: "Lightweight and portable Great condition Includes accessories.", price: 128.15 },
  { title: "Shower Caddy Bundle", description: "Helps with classes Gently worn Lightweight and portable.", price: 181.3 },
  { title: "Dorm Tool Kit", description: "Barely used Great condition Helps with classes.", price: 229.48 },
  { title: "Rolling Storage Cart", description: "Perfect for dorms Great condition Gently worn.", price: 92.41 },
  { title: "Noise Machine", description: "Gently worn Lightweight and portable Gently worn.", price: 216.8 },
  { title: "Dorm Whiteboard", description: "Helps with classes Gently worn Must pick up on campus.", price: 96.08 }
]

generated_listings.each_with_index do |listing_info, index|
  sample_users << {
    first_name: "Student",
    last_name: "Number#{ index + 1 }",
    email_address: "student#{ index + 1 }@u.northwestern.edu",
    username: "student#{ index + 1 }",
    password: "password123",
    listings: [
      {
        title: listing_info.fetch(:title),
        description: listing_info.fetch(:description),
        price: listing_info.fetch(:price)
      }
    ]
  }
end

ActiveRecord::Base.transaction do
  sample_users.each do |attributes|
    listings = attributes.delete(:listings) || []
    password = attributes.delete(:password)
    identifier_email = attributes[:email_address]
    identifier_username = attributes[:username]

    attributes[:confirmed_at] ||= Time.current

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
