require "rails_helper"

RSpec.describe "Listing filters", type: :system do
  fixtures :users, :listings

  let(:user) { users(:one) }

  it "filters listings by category" do
    sign_in_as(user)
    visit listings_path

    check "Furniture", allow_label_click: true
    click_on "Search"

    within "#listings" do
      expect(page).to have_text("MacBook Pro")
      expect(page).not_to have_text("Calculus Textbook")
    end
  end
end
