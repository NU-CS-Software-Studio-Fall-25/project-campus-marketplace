require "securerandom"
require "rspec/expectations"

module RouteHelpers
  include Rails.application.routes.url_helpers

  def default_url_options
    {}
  end
end

World(RouteHelpers)
World(RSpec::Matchers)

Given("I am a confirmed user") do
  suffix = SecureRandom.hex(4)
  @current_password = "password123"

  @current_user = User.create!(
    first_name: "Test",
    last_name: "User",
    email_address: "student#{suffix}@u.northwestern.edu",
    username: "student#{suffix}",
    password: @current_password,
    password_confirmation: @current_password,
    confirmed_at: Time.current
  )
end

Given("I am signed in") do
  visit new_session_path
  fill_in "email_address", with: @current_user.email_address
  fill_in "password", with: @current_password
  click_button "Sign in"

  expect(page).to have_selector(:link_or_button, "Sign out")
end

When("I create a listing with the following details:") do |table|
  details = table.rows_hash

  visit mine_listings_path
  click_link "New listing"

  fill_in "Title", with: details.fetch("Title")
  fill_in "Description", with: details.fetch("Description")
  fill_in "Price", with: details.fetch("Price")

  attach_file("listing_image", Rails.root.join("test/fixtures/files/placeholder.png"))

  click_button "Create Listing"
  @created_listing = @current_user.listings.order(created_at: :desc).first
end



Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end
Given("I have created a listing with the following details:") do |table|
  step("I create a listing with the following details:", table)
  @created_listing = @current_user.listings.order(created_at: :desc).first
end



Then("I should see a button to delete the listing on the all listings page") do
  visit listings_path
  within("##{ActionView::RecordIdentifier.dom_id(@created_listing)}") do
    expect(page).to have_button("Delete", exact: true)
  end
end

When("I click the delete button for that listing") do
  visit listings_path
  within("##{dom_id(@created_listing)}") do
    click_button "Delete", exact: true
  end
end



When("Once I click that button I should receive a notification that my listing was deleted") do
  within("##{ActionView::RecordIdentifier.dom_id(@created_listing)}") do
    accept_confirm { click_button "Delete", exact: true }
  end
  expect(page).to have_current_path(mine_listings_path)
  expect(page).to have_content("Listing was successfully destroyed.")
end
