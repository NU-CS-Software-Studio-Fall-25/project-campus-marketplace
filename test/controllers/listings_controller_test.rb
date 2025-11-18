require "test_helper"

class ListingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @listing = listings(:one)
    @user = users(:one)
    sign_in_as(@user)
    @listing.image.attach(
      io: file_fixture("placeholder.png").open,
      filename: "placeholder.png",
      content_type: "image/png"
    )
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
    listing_params = { title: "New Listing", description: "Sample description", price: 19.99, category: "electronics" }
    image = fixture_file_upload("placeholder.png", "image/png")

    assert_difference("Listing.count") do
      post listings_url, params: { listing: listing_params.merge(image: image) }
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
    patch listing_url(@listing), params: { listing: { description: "Updated description", category: "furniture" } }
    assert_redirected_to listing_url(@listing)
    @listing.reload
    assert_equal "Updated description", @listing.description
    assert_equal "furniture", @listing.category
  end

  test "should destroy listing" do
    assert_difference("Listing.count", -1) do
      delete listing_url(@listing)
    end

    assert_redirected_to mine_listings_url
  end

  test "index filters by category" do
    get listings_url, params: { categories: [ "electronics" ] }
    assert_response :success
    assert_match(/Calculus Textbook/, @response.body)
    assert_no_match(/MacBook Pro/, @response.body)
  end
end
