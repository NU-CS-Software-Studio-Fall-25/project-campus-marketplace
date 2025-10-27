require "test_helper"

class ListingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @listing = listings(:one)
    @user = users(:one)
    sign_in_as(@user)
  end

  test "should get index" do
    get listings_url
    assert_response :success
  end

  test "should get new" do
    get new_listing_url
    assert_response :success
  end

  test "should create listing" do
    listing_params = { title: "New Listing", description: "Sample description", price: 19.99 }

    assert_difference("Listing.count") do
      post listings_url, params: { listing: listing_params }
    end

    assert_redirected_to listing_url(Listing.last)
    assert_equal @user, Listing.last.user
  end

  test "should show listing" do
    get listing_url(@listing)
    assert_response :success
  end

  test "should get edit" do
    get edit_listing_url(@listing)
    assert_response :success
  end

  test "should update listing" do
    patch listing_url(@listing), params: { listing: { description: "Updated description" } }
    assert_redirected_to listing_url(@listing)
    @listing.reload
    assert_equal "Updated description", @listing.description
  end

  test "should destroy listing" do
    assert_difference("Listing.count", -1) do
      delete listing_url(@listing)
    end

    assert_redirected_to mine_listings_url
  end
end
