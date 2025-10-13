# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

20.times do |i|
  User.create!(
    name:  "User #{i + 1}",
    email: "user#{i + 1}@example.com"
  )

  Listing.create!(
    title:       "Product #{i + 1}",
    description: "Sample description for listing #{i + 1}. This is placeholder text.",
    price:       (10 + (i % 91)) # cycles 10..100
  )
end
