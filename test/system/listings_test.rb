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

    fill_in "Title", with: "New Listing Title"
    fill_in "Description", with: "New listing description"
    fill_in "Price", with: "25.00"
    select "Electronics", from: "Category"
    attach_file "Image", file_fixture("placeholder.png")

    click_on "Create Listing"

    assert_text "Listing was successfully created."
  end

  test "should update Listing" do
    sign_in_as(@user)
    visit edit_listing_url(@listing)

    # Wait for the edit page to load to avoid filling fields on the index page
    assert_selector "h1", text: "Editing Listing"

    fill_in "Description", with: "Updated description"
    fill_in "Price", with: @listing.price
    fill_in "Title", with: @listing.title
    select "Furniture", from: "Category"
    click_on "Update Listing"

    assert_text "Listing was successfully updated."
    assert_text "Updated description"
  end

  test "should destroy Listing" do
    sign_in_as(@user)
    visit mine_listings_url
    accept_confirm do
      click_on "Delete", match: :first
    end

    assert_no_text @listing.title
  end

  test "search filters listings" do
    sign_in_as(@user)
    visit listings_url

    fill_in "Search listings", with: "Calculus"
    click_on "Search"

    # Wait for the results area to update to avoid timing races in CI/headless
    within "#listings" do
      assert_selector "div", text: "Calculus Textbook"
      assert_no_selector "div", text: "MacBook Pro"
    end
  end

  test "category filter limits listings" do
    sign_in_as(@user)
    visit listings_url

    # Wait for the page and filters to be fully loaded
    assert_selector "input#category_filter_furniture"

    find("label", text: "Furniture").click

    # Give JavaScript time to update the checkbox state
    sleep 0.1
    assert_selector "input#category_filter_furniture:checked"

    click_on "Search"

    assert_no_text "Calculus Textbook"
    assert_text "MacBook Pro"
  end

  test "price range filter limits listings" do
    sign_in_as(@user)
    visit listings_url

    find("label", text: "Over $100").click
    click_on "Search"

    within "#listings" do
      assert_text "MacBook Pro"
      assert_no_text "Calculus Textbook"
    end
  end
end
