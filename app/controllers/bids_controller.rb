class BidsController < ApplicationController
  before_action :set_listing, only: :create
  before_action :set_bid, only: %i[ accept reject counter ]
  before_action :authorize_listing_owner!, only: %i[ accept reject counter ]

  def create
    @bid = @listing.bids.new(bid_params.merge(buyer: current_user))

    if @bid.save
      BidMailer.with(bid: @bid).new_bid_notification.deliver_later
      redirect_to listing_path(@listing), notice: "Your offer was sent to the seller."
    else
      redirect_to listing_path(@listing), alert: @bid.errors.full_messages.to_sentence
    end
  end

  def accept
    respond_to_bid!(:accepted, response_message: params.dig(:bid, :response_message))
    redirect_to listing_path(@bid.listing), notice: "You accepted the offer."
  rescue ActiveRecord::RecordInvalid => e
    handle_bid_error(e)
  end

  def reject
    respond_to_bid!(:rejected, response_message: params.dig(:bid, :response_message))
    redirect_to listing_path(@bid.listing), notice: "You rejected the offer."
  rescue ActiveRecord::RecordInvalid => e
    handle_bid_error(e)
  end

  def counter
    counter_params = params.require(:bid).permit(:response_amount, :response_message)

    if counter_params[:response_amount].blank?
      redirect_to listing_path(@bid.listing), alert: "Enter a counter offer amount."
      return
    end

    respond_to_bid!(
      :countered,
      response_amount: counter_params[:response_amount],
      response_message: counter_params[:response_message]
    )

    redirect_to listing_path(@bid.listing), notice: "Counter offer sent."
  rescue ArgumentError => e
    redirect_to listing_path(@bid.listing), alert: e.message
  rescue ActiveRecord::RecordInvalid => e
    handle_bid_error(e)
  end

  private
    def set_listing
      @listing = Listing.find(params[:listing_id])
    end

    def set_bid
      @bid = Bid.find(params[:id])
    end

    def authorize_listing_owner!
      unless @bid.listing.user == current_user
        redirect_to listing_path(@bid.listing), alert: "You are not authorized to manage this bid."
      end
    end

    def bid_params
      params.require(:bid).permit(:amount, :message)
    end

    def respond_to_bid!(new_status, response_amount: nil, response_message: nil)
      amount_value = response_amount.presence
      amount_value = BigDecimal(amount_value) if amount_value

      @bid.respond!(
        new_status: new_status,
        responder: current_user,
        response_amount: amount_value,
        response_message: response_message.presence
      )

      BidMailer.with(bid: @bid).bid_response_notification.deliver_later
    end

    def handle_bid_error(error)
      redirect_to listing_path(@bid.listing), alert: error.record.errors.full_messages.to_sentence
    end
end
