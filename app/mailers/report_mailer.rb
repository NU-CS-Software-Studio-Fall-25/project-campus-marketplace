class ReportMailer < ApplicationMailer
  default to: ENV.fetch("REPORTS_RECIPIENT_EMAIL", ENV.fetch("MAIL_FROM_ADDRESS", "nucampusmarketplace@gmail.com"))

  def new_report(report)
    @report = report
    @listing = report.listing
    @reporter = report.reporter

    mail(
      subject: "[Campus Marketplace] New listing report for ##{@listing.id} - #{@listing.title}"
    )
  end

  def listing_owner_notification(report)
    @report = report
    @listing = report.listing
    @reporter = report.reporter

    mail(
      to: @listing.user.email_address,
      subject: "[Campus Marketplace] Your listing was reported"
    )
  end

  def listing_removed_for_safety(listing, user, reason)
    @listing = listing
    @user = user
    @reason = reason

    mail(
      to: user.email_address,
      subject: "[Campus Marketplace] Your listing was removed for safety reasons"
    )
  end
end
