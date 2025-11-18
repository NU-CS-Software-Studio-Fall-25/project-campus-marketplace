class BidMailer < ApplicationMailer
  helper ActionView::Helpers::NumberHelper

  def new_bid_notification
    @bid = params.fetch(:bid)
    @listing = @bid.listing
    @buyer = @bid.buyer

    mail(
      to: @listing.user.email_address,
      subject: "#{@buyer.full_name} offered #{number_to_currency(@bid.amount)} for #{@listing.title}"
    )
  end

  def bid_response_notification
    @bid = params.fetch(:bid)
    @listing = @bid.listing
    @seller = @listing.user

    mail(
      to: @bid.buyer.email_address,
      subject: "Update on your #{@listing.title} offer"
    )
  end
end
