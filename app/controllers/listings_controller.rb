class ListingsController < ApplicationController
  PRICE_RANGES = {
    "free" => { label: "Free", min: 0, max: 0 },
    "under_25" => { label: "Under $25", min: 0, min_comparison: ">", max: 25 },
    "25_to_100" => { label: "$25 - $100", min: 25, min_comparison: ">", max: 100 },
    "over_100" => { label: "Over $100", min: 100, min_comparison: ">" }
  }.freeze

  helper_method :price_range_options

  before_action :set_listing, only: :show
  before_action :set_owned_listing, only: %i[ edit update destroy ]

  # POST /listings/generate_description
  def generate_description
    signed_id = params[:signed_id]

    if signed_id.blank?
      return render json: { error: "No image provided" }, status: :unprocessable_entity
    end

    # Check if feature is enabled
    unless Rails.application.config.ai_description_enabled
      return render json: {
        error: "AI description generation is currently unavailable. Please enter a description manually.",
        disabled: true
      }, status: :service_unavailable
    end

    # Check rate limit before processing
    limit = Rails.application.config.ai_description_rate_limit
    remaining = RateLimiter.remaining("ai_description", limit, 3600)

    if remaining <= 0
      return render json: {
        error: "AI description limit reached. Please try again later or enter a description manually.",
        rate_limited: true
      }, status: :too_many_requests
    end

    blob = ActiveStorage::Blob.find_signed(signed_id)
    result = ImageAnalyzerService.new(blob).generate_description

    if result.present? && result[:description].present?
      render json: {
        description: result[:description],
        category: result[:category],
        remaining_generations: remaining - 1
      }
    else
      render json: {
        error: "Could not generate description. Please try again or enter manually.",
        remaining_generations: remaining
      }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Image not found" }, status: :not_found
  rescue StandardError => e
    Rails.logger.error "Generate description error: #{e.message}"
    render json: { error: "An error occurred while generating the description" }, status: :internal_server_error
  end

  # GET /listings or /listings.json
  def index
    @query = params[:q].to_s.strip
    @category_filters = extract_categories(params[:categories])
    @price_range_filters = extract_price_ranges(params[:price_ranges])
    @selected_categories = normalize_categories(params[:categories])
    @selected_price_ranges = normalize_price_ranges(params[:price_ranges])
    @listings = listings_scope(@query, @selected_categories, @selected_price_ranges)
    pagy_params = {}
    pagy_params[:q] = @query if @query.present?
    pagy_params[:categories] = @selected_categories if @selected_categories.present?
    pagy_params[:price_ranges] = @selected_price_ranges if @selected_price_ranges.present?
    @pagy, @listings = pagy(@listings.order(created_at: :desc), items: 12, params: pagy_params)

    respond_to do |format|
      format.html
      format.json
    end
  end

  # GET /listings/mine
  def mine
    @listings = Current.user.listings.order(created_at: :desc)
  end

  def filter
    query = params[:q].to_s.strip
    selected_categories = normalize_categories(params[:categories])
    selected_price_ranges = normalize_price_ranges(params[:price_ranges])
    listings = listings_scope(query, selected_categories, selected_price_ranges)
    pagy_params = {}
    pagy_params[:q] = query if query.present?
    pagy_params[:categories] = selected_categories if selected_categories.present?
    pagy_params[:price_ranges] = selected_price_ranges if selected_price_ranges.present?
    pagy, listings = pagy(listings.order(created_at: :desc), items: 12, params: pagy_params)

    pagination_html = pagy.pages > 1 ? view_context.pagy_nav(pagy) : ""
    summary_html = render_to_string(partial: "listings/summary", locals: { pagy: pagy }, formats: [ :html ])

    render json: {
      html: render_to_string(partial: "listings/listings", locals: { listings: listings, query: query }, formats: [ :html ]),
      pagination: pagination_html,
      summary: summary_html
    }
  end

  def suggestions
    query = params[:q].to_s.strip
    selected_categories = normalize_categories(params[:categories])
    selected_price_ranges = normalize_price_ranges(params[:price_ranges])

    suggestions = []

    if query.present?
      scope = listings_scope(query, selected_categories, selected_price_ranges)
      suggestions = scope.order(created_at: :desc).limit(8).pluck(:title)
    end

    render json: { suggestions: suggestions }
  end

  # GET /listings/1 or /listings/1.json
  def show
  end

  # GET /listings/new
  def new
    @listing = Current.user.listings.build(category: :other)
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
        Rails.logger.error "Listing create failed: #{ @listing.errors.full_messages.join(", ") }"
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /listings/1 or /listings/1.json
  def update
    attrs = listing_attributes

    respond_to do |format|
      if @listing.update(attrs)
        format.html { redirect_to @listing, notice: "Listing was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @listing }
      else
        Rails.logger.error "Listing update failed: #{ @listing.errors.full_messages.join(", ") }"
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

  def price_range_options
    PRICE_RANGES
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
      @listing_params ||= params.require(:listing).permit(:title, :description, :price, :image, :category)
    end

    def listing_attributes
      listing_params.tap do |attrs|
        attrs.delete(:image) if attrs.key?(:image) && attrs[:image].respond_to?(:blank?) && attrs[:image].blank?
      end
    end

    def listings_scope(query, categories, price_ranges)
      scope = Listing.includes(:user)
      scope = scope.where(category: categories) if categories.present?
      scope = apply_price_filter(scope, price_ranges)

      return scope unless query.present?

      sanitized = ActiveRecord::Base.sanitize_sql_like(query)
      scope.where(
        "title ILIKE :prefix OR title ILIKE :mid_prefix",
        prefix: "#{sanitized}%",
        mid_prefix: "% #{sanitized}%"
      )
    end

    def normalize_categories(raw_categories)
      categories = extract_categories(raw_categories)
      categories.presence || Listing.categories.keys
    end

    def normalize_price_ranges(raw_ranges)
      ranges = extract_price_ranges(raw_ranges)
      ranges.presence || PRICE_RANGES.keys
    end

    def apply_price_filter(scope, price_ranges)
      selected = Array(price_ranges) & PRICE_RANGES.keys
      return scope if selected.empty? || selected.length == PRICE_RANGES.length

      price_column = Listing.arel_table[:price]

      predicates = selected.filter_map do |key|
        range = PRICE_RANGES[key]
        next unless range

        parts = []

        if range.key?(:min)
          comparator = arel_operator(range[:min_comparison], :gteq)
          parts << price_column.public_send(comparator, range[:min])
        end

        if range.key?(:max)
          comparator = arel_operator(range[:max_comparison], :lteq)
          parts << price_column.public_send(comparator, range[:max])
        end

        next if parts.empty?

        parts.reduce { |memo, node| memo.and(node) }
      end

      return scope if predicates.empty?

      combined = predicates.reduce { |memo, node| memo.or(node) }
      scope.where(combined)
    end

    def extract_categories(raw_categories)
      Array(raw_categories).map { |category| category.to_s.presence }.compact & Listing.categories.keys
    end

    def extract_price_ranges(raw_ranges)
      Array(raw_ranges).map { |range| range.to_s.presence }.compact & PRICE_RANGES.keys
    end

    def arel_operator(comparison, default)
      case comparison
      when ">"
        :gt
      when ">="
        :gteq
      when "<"
        :lt
      when "<="
        :lteq
      else
        default
      end
    end
end
