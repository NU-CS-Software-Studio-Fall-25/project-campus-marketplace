require "rails_helper"

RSpec.describe "Listing filters", type: :system do
  fixtures :users, :listings

  let(:user) { users(:one) }

  it "filters listings by category" do
    sign_in_as(user)
    visit listings_path(categories: [ "furniture" ])

    expect(page).to have_text("Showing 1-1 of 1 listings", wait: 5)

    within "#listings", wait: 5 do
      expect(page).to have_text("MacBook Pro")
      expect(page).not_to have_text("Calculus Textbook")
    end
  end
end
