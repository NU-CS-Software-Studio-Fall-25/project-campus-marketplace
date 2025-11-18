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

    fill_in "Title", with: @listing.title
    fill_in "Description", with: @listing.description
    fill_in "Price", with: @listing.price
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

    assert_no_text "Editing Listing"
    assert_text "Updated description"
  end

  test "should destroy Listing" do
    sign_in_as(@user)
    visit mine_listings_url
    page.execute_script("window.confirm = () => true")
    click_on "Delete", match: :first

    assert_text "Listing was successfully destroyed."
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

    find("#price_range_filter_over_100", visible: :all, wait: 5).click
    assert_checked_field "price_range_filter_over_100", wait: 2
    page.execute_script("document.getElementById('price_range_filter_over_100').dispatchEvent(new Event('input', { bubbles: true }))")

    assert_no_text "Calculus Textbook"
    assert_text "MacBook Pro"
  end
end
