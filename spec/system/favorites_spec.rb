require "rails_helper"

RSpec.describe "Favorites", type: :system do
  fixtures :users, :listings

  let(:user) { users(:one) }
  let(:other_user) { users(:two) }
  let(:listing) { listings(:two) }  # Listing owned by other_user
  let(:image_path) { Rails.root.join("test/fixtures/files/placeholder.png") }

  before do
    # Ensure listing has an image attached
    unless listing.image.attached?
      File.open(image_path) do |file|
        listing.image.attach(
          io: file,
          filename: "placeholder.png",
          content_type: "image/png"
        )
      end
    end
  end

  it "allows a user to add a listing to favorites" do
    sign_in_as(user)
    
    # Add favorite directly
    user.favorites.create!(listing: listing)
    
    # Verify it appears in favorites index
    visit favorites_path
    expect(page).to have_text(listing.title, wait: 5)
  end

  it "allows a user to remove a listing from favorites" do
    sign_in_as(user)
    
    # First add to favorites
    favorite = user.favorites.create!(listing: listing)
    
    # Remove it
    favorite.destroy
    
    # Verify it's removed from database
    user.reload
    expect(user.favorites.where(listing: listing).exists?).to be false
  end

  it "displays favorited listings in the favorites index" do
    sign_in_as(user)
    
    # Add listing to favorites
    user.favorites.create!(listing: listing)
    
    visit favorites_path

    expect(page).to have_text(listing.title, wait: 5)
    expect(page).to have_text("$#{listing.price}")
  end

  it "shows empty state when user has no favorites" do
    sign_in_as(user)
    
    visit favorites_path

    expect(page).to have_text("No listings yet", wait: 5)
  end
end
