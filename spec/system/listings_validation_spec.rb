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

    expect(page).to have_content("Image must be attached", wait: 5)
  end
end
