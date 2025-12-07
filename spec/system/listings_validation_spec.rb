require "rails_helper"

RSpec.describe "Listing validations", type: :system do
  fixtures :users

  let(:user) { users(:one) }

  it "shows an error when creating a listing without an image" do
    sign_in_as(user)
    visit new_listing_path

    fill_in "Title", with: "Campus Bike"
    fill_in "Description", with: "Bike with a broken chain, needs repair."
    fill_in "Price", with: "75"
    select "Other", from: "Category"

    click_button "Create Listing"

    # Should stay on the form page and not create the listing
    expect(page).to have_current_path(new_listing_path, wait: 5)
    expect(Listing.where(title: "Campus Bike").exists?).to be false
  end
end
