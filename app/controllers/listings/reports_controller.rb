module Listings
  class ReportsController < ApplicationController
    def create
      @listing = Listing.find(params[:listing_id])

      if @listing.user_id == current_user.id
        return redirect_back fallback_location: @listing, alert: "You cannot report your own listing."
      end

      @report = @listing.reports.find_or_initialize_by(reporter: current_user)
      @report.assign_attributes(report_params)
      @report.status = :open

      if @report.save
        current_user.hidden_listings.find_or_create_by!(listing: @listing)
        ReportMailer.new_report(@report).deliver_later
        ReportMailer.listing_owner_notification(@report).deliver_later
        redirect_back fallback_location: @listing, notice: "Thanks for letting us know. We've hidden this listing for you."
      else
        redirect_back fallback_location: @listing, alert: @report.errors.full_messages.to_sentence
      end
    end

    private
      def report_params
        params.require(:report).permit(:reason, :details)
      end
  end
end
