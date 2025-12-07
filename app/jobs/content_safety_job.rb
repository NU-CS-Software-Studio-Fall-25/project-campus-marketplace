class ContentSafetyJob < ApplicationJob
  queue_as :default

  # Run this job to scan all existing listings for harmful content
  def perform
    return unless Rails.application.config.content_safety_enabled

    Rails.logger.info "Starting content safety scan of all listings..."

    removed_count = 0
    checked_count = 0

    Listing.find_each do |listing|
      checked_count += 1

      safety_service = ContentSafetyService.new(listing)
      result = safety_service.check_safety

      unless result[:safe]
        Rails.logger.warn "Removing unsafe listing ##{listing.id}: #{result[:reason]}"

        # Notify the user
        notify_user_of_removal(listing, result[:reason])

        # Remove the listing
        listing.destroy
        removed_count += 1
      end

      # Add a small delay to avoid rate limiting
      sleep 0.5 if checked_count % 10 == 0
    rescue StandardError => e
      Rails.logger.error "Error checking listing ##{listing.id}: #{e.message}"
      next
    end

    Rails.logger.info "Content safety scan complete. Checked: #{checked_count}, Removed: #{removed_count}"
  end

  private

  def notify_user_of_removal(listing, reason)
    user = listing.user
    return unless user

    # Send email notification
    begin
      ReportMailer.listing_removed_for_safety(listing, user, reason).deliver_later
    rescue StandardError => e
      Rails.logger.error "Failed to send removal notification: #{e.message}"
    end
  end
end
