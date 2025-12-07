require "rails_helper"

RSpec.describe "Listing deletion", type: :system do
  fixtures :users, :listings

  let(:user) { users(:one) }
  let(:listing) { listings(:one) }
  let(:image_path) { Rails.root.join("test/fixtures/files/placeholder.png") }

  before do
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

  it "lets a user delete their listing" do
    sign_in_as(user)

    visit mine_listings_path

    expect(page).to have_text(listing.title, wait: 5)
    expect(page).to have_selector(:link_or_button, "Delete", wait: 5)

    click_on "Delete", match: :first

    begin
      page.driver.browser.switch_to.alert.accept
    rescue Selenium::WebDriver::Error::NoSuchAlertError
      # No confirmation alert shown
    end

    expect(page).to have_text("Listing was successfully destroyed.", wait: 5)
    expect(page).not_to have_text(listing.title)
  end
end
