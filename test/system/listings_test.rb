require "application_system_test_case"

class ListingsTest < ApplicationSystemTestCase
  setup do
    @listing = listings(:one)
    @user = users(:one)

    unless @listing.image.attached?
      @listing.image.attach(
        io: file_fixture("placeholder.png").open,
        filename: "placeholder.png",
        content_type: "image/png"
      )
    end
  end

  test "visiting the index" do
    sign_in_as(@user)
    visit listings_url
    assert_selector "h1", text: "All Listings"
  end

  test "should create listing" do
    sign_in_as(@user)
    visit mine_listings_url
    click_on "New listing"

    fill_in "Description", with: @listing.description
    fill_in "Price", with: @listing.price
    fill_in "Title", with: @listing.title
    select "Electronics", from: "Category"
    attach_file "Image", file_fixture("placeholder.png")
    click_on "Create Listing"

    assert_text "Listing was successfully created."
  end

  test "should update Listing" do
    sign_in_as(@user)
    visit mine_listings_url
  click_on "Edit", match: :first

  # Wait for the edit page to load to avoid filling fields on the index page
  assert_selector "h1", text: "Editing Listing"

  fill_in "Description", with: "Updated description"
    fill_in "Price", with: @listing.price
    fill_in "Title", with: @listing.title
    select "Furniture", from: "Category"
    click_on "Update Listing"

    assert_text "Listing was successfully updated."
  end

  test "should destroy Listing" do
    sign_in_as(@user)
    visit mine_listings_url
    accept_confirm "Delete this listing? This action cannot be undone." do
      click_on "Delete", match: :first
    end

    assert_text "Listing was successfully destroyed."
  end

  test "search filters listings" do
    sign_in_as(@user)
    visit listings_url

    fill_in "Search listings", with: "Calculus"
    click_on "Search"

    assert_text "Calculus Textbook"
    assert_no_text "MacBook Pro"
  end

  test "category filter limits listings" do
    sign_in_as(@user)
    visit listings_url

    check "Furniture"
    assert_selector "input#category_filter_furniture:checked"
    page.execute_script("document.getElementById('category_filter_furniture').dispatchEvent(new Event('input', { bubbles: true }))")

    click_on "Search"

    assert_no_text "Calculus Textbook"
    assert_text "MacBook Pro"
  end

  test "price range filter limits listings" do
    sign_in_as(@user)
    visit listings_url

  check "Over $100"

  # Ensure checkbox is actually checked
  assert_selector "input#price_range_filter_over_100:checked"

  # Fire an input event on the checkbox to trigger the Stimulus controller (update -> AJAX)
  page.execute_script("document.getElementById('price_range_filter_over_100').dispatchEvent(new Event('input', { bubbles: true }))")

  # Wait for the expensive listing to remain and the cheap one to disappear
  assert_selector "#listing_298486374", wait: 5
  assert_no_selector "#listing_980190962", wait: 5
  end
end
