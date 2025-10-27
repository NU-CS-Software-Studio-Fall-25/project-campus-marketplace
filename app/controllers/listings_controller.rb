class ListingsController < ApplicationController
  before_action :set_listing, only: :show
  before_action :set_owned_listing, only: %i[ edit update destroy ]

  # GET /listings or /listings.json
  def index
    @listings = Listing.includes(:user).order(created_at: :desc)
  end

  # GET /listings/mine
  def mine
    @listings = Current.user.listings.order(created_at: :desc)
  end

  # GET /listings/1 or /listings/1.json
  def show
  end

  # GET /listings/new
  def new
    @listing = Current.user.listings.build
  end

  # GET /listings/1/edit
  def edit
  end

  # POST /listings or /listings.json
  def create
    @listing = Current.user.listings.build(listing_attributes)

    respond_to do |format|
      if @listing.save
        format.html { redirect_to @listing, notice: "Listing was successfully created." }
        format.json { render :show, status: :created, location: @listing }
      else
        Rails.logger.error "Listing create failed: #{ @listing.errors.full_messages.join(', ') }"
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /listings/1 or /listings/1.json
  def update
    attrs = listing_attributes
    remove_image = remove_image_requested? && attrs[:image].blank?

    respond_to do |format|
      if @listing.update(attrs)
        purge_listing_image(@listing) if remove_image
        format.html { redirect_to @listing, notice: "Listing was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @listing }
      else
        Rails.logger.error "Listing update failed: #{ @listing.errors.full_messages.join(', ') }"
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /listings/1 or /listings/1.json
  def destroy
    @listing.destroy!

    respond_to do |format|
      format.html { redirect_to mine_listings_path, notice: "Listing was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.includes(:user).find(params[:id])
    end

    def set_owned_listing
      @listing = Current.user.listings.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def listing_params
      @listing_params ||= params.require(:listing).permit(:title, :description, :price, :image, :remove_image)
    end

    def listing_attributes
      listing_params.except(:remove_image)
    end

    def remove_image_requested?
      ActiveModel::Type::Boolean.new.cast(listing_params[:remove_image])
    end

    def purge_listing_image(listing)
      listing.image.purge_later if listing.image.attached?
    end
end
