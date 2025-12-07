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

    # Wait for the new listing form to load
    assert_selector "h1", text: "Add a new item", wait: 5
    assert_selector "form"

    fill_in "Title", with: "New Listing Title"
    fill_in "Description", with: "New listing description"
    fill_in "Price", with: "25.00"
    select "Electronics", from: "Category"
    attach_file "Image", file_fixture("placeholder.png")

    click_on "Create Listing"

    assert_text "Listing was successfully created.", wait: 5
  end

  test "should update Listing" do
    sign_in_as(@user)
    visit edit_listing_url(@listing)

    # Wait for the edit page to load to avoid filling fields on the index page
    assert_selector "h1", text: "Editing Listing"

    fill_in "Title", with: @listing.title
    fill_in "Description", with: "Updated description"
    fill_in "Price", with: @listing.price
    select "Furniture", from: "Category"

    click_on "Update Listing"

    # Wait for redirect to show page
    assert_text "Listing was successfully updated.", wait: 5
    assert_text "Updated description"
  end

  test "should destroy Listing" do
    sign_in_as(@user)
    visit mine_listings_url

    # Click delete and handle the Turbo confirmation
    page.driver.browser.switch_to.alert.accept rescue nil
    click_on "Delete", match: :first

    # Wait a moment for any confirmation dialog
    sleep 0.3

    # Accept any confirmation that appears
    begin
      page.driver.browser.switch_to.alert.accept
    rescue Selenium::WebDriver::Error::NoSuchAlertError
      # No alert present, continue
    end

    assert_no_text @listing.title, wait: 5
  end

  test "search filters listings" do
    sign_in_as(@user)
    visit listings_url

    fill_in "Search listings", with: "Calculus"
    click_on "Search"

    # Wait for the results area to update to avoid timing races in CI/headless
    within "#listings" do
      assert_text "Calculus Textbook", wait: 5
      assert_no_text "MacBook Pro", wait: 5
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

    # Wait for filters to load
    assert_selector "label", text: "Over $100"

    check "Over $100", allow_label_click: true
    assert_checked_field "Over $100"

    click_on "Search"

    # Wait for filtered results
    within "#listings", wait: 5 do
      assert_text "MacBook Pro"
      assert_no_text "Calculus Textbook"
    end
  end
end
