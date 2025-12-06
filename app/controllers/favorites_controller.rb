class FavoritesController < ApplicationController
  before_action :set_listing, only: %i[ create destroy ]

  def index
    @listings = Current.user.liked_listings.includes(:user).order(created_at: :desc)
  end

  def create
    current_user.favorites.find_or_create_by!(listing: @listing)
    @listing.reload
    flash.now[:notice] = "Saved to likes."
    respond_to do |format|
      format.html { redirect_back fallback_location: listings_path, notice: "Saved to likes." }
      format.turbo_stream
    end
  end

  def destroy
    favorite = current_user.favorites.find_by(listing: @listing)
    favorite&.destroy!
    @listing.reload
    flash.now[:notice] = "Removed from likes."
    respond_to do |format|
      format.html { redirect_back fallback_location: listings_path, notice: "Removed from likes." }
      format.turbo_stream
    end
  end

  private
    def set_listing
      @listing = Listing.find(params[:listing_id])
    end
end
