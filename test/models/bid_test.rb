require "test_helper"

class BidTest < ActiveSupport::TestCase
  setup do
    @listing = listings(:one)
    @buyer = users(:two)
  end

  test "valid bid" do
    bid = Bid.new(listing: @listing, buyer: @buyer, amount: 25)
    assert bid.valid?
  end

  test "buyer cannot bid on own listing" do
    bid = Bid.new(listing: @listing, buyer: @listing.user, amount: 10)
    assert_not bid.valid?
    assert_includes bid.errors.full_messages, "You cannot bid on your own listing."
  end

  test "respond! updates status and prevents non owners" do
    bid = Bid.create!(listing: @listing, buyer: @buyer, amount: 15)

    assert_raises(ArgumentError) do
      bid.respond!(new_status: :accepted, responder: users(:two))
    end

    travel_to Time.current do
      bid.respond!(new_status: :accepted, responder: @listing.user, response_message: "See you soon")
      assert_equal "accepted", bid.status
      assert_equal Time.current, bid.responded_at
      assert_equal "See you soon", bid.response_message
    end
  end
end
