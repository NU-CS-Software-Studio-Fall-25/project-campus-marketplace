require "securerandom"
require "rspec/expectations"
require "action_view/record_identifier"

module RouteHelpers
  include Rails.application.routes.url_helpers

  def default_url_options
    {}
  end
end

World(RouteHelpers)
World(RSpec::Matchers)
World(ActionView::RecordIdentifier)

Given("I am a confirmed user") do
  suffix = SecureRandom.hex(4)
  @current_password = default_password

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
  category_label = (details["Category"] || "Other").to_s.titleize

  visit mine_listings_path
  click_link "New listing"

  fill_in "Title", with: details.fetch("Title")
  fill_in "Description", with: details.fetch("Description")
  fill_in "Price", with: details.fetch("Price")
  select category_label, from: "Category"

  attach_file("listing_image", Rails.root.join("test/fixtures/files/placeholder.png"))

  click_button "Create Listing"
  @created_listing = @current_user.listings.order(created_at: :desc).first
end

Given("I have created a listing with the following details:") do |table|
  step("I create a listing with the following details:", table)
end

When("I attempt to create a listing without an image") do
  visit new_listing_path

  fill_in "Title", with: "Campus Bike"
  fill_in "Description", with: "Bike with a broken chain, needs repair."
  fill_in "Price", with: "75"
  select "Other", from: "Category"

  click_button "Create Listing"
end

When("I update the listing title to {string} and price to {string}") do |title, price|
  raise "No listing to update" unless @created_listing.present?

  visit edit_listing_path(@created_listing)
  fill_in "Title", with: title
  fill_in "Price", with: price
  click_button "Update Listing"
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should not see {string}") do |text|
  expect(page).not_to have_content(text)
end

Then("I should see a button to delete the listing on the all listings page") do
  visit listings_path
  within("##{dom_id(@created_listing)}") do
    expect(page).to have_selector(:link_or_button, "Delete", exact: true)
  end
end

When("I click the delete button for that listing") do
  visit listings_path
  within("##{dom_id(@created_listing)}") do
    click_on "Delete", exact: true
  end
end

When("I filter listings by category {string}") do |category|
  visit listings_path
  target_label = category.to_s.titleize

  Listing.categories.keys.each do |key|
    label = key.titleize
    next unless page.has_field?(label, type: "checkbox")

    if label.casecmp?(target_label)
      check(label, allow_label_click: true)
    else
      uncheck(label, allow_label_click: true)
    end
  end

  click_button "Search"
end
