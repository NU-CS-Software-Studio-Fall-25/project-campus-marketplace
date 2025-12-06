class HiddenListingsController < ApplicationController
  before_action :set_listing

  def create
    message_key = :notice
    message_text = "Listing hidden from your results."

    if @listing.user_id == current_user.id
      message_key = :alert
      message_text = "You cannot hide your own listing."
      flash.now[:alert] = message_text
    else
      current_user.hidden_listings.find_or_create_by!(listing: @listing)
      flash.now[:notice] = message_text
    end

    respond_to do |format|
      format.html { redirect_back fallback_location: listings_path, status: :see_other, flash: { message_key => message_text } }
      format.turbo_stream
    end
  end

  def destroy
    hidden_listing = current_user.hidden_listings.find_by(listing: @listing)
    hidden_listing&.destroy!
    flash.now[:notice] = "Listing will show in results again."

    respond_to do |format|
      format.html { redirect_back fallback_location: listings_path, status: :see_other, notice: "Listing will show in results again." }
      format.turbo_stream
    end
  end

  private
    def set_listing
      @listing = Listing.find(params[:listing_id])
    end
end
