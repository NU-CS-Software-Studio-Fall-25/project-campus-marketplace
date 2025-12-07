namespace :safety do
  desc "Scan all listings for harmful content and remove unsafe ones"
  task scan: :environment do
    puts "Starting content safety scan..."
    puts "Content Safety Enabled: #{Rails.application.config.content_safety_enabled}"

    unless Rails.application.config.content_safety_enabled
      puts "Content safety checking is disabled. Set CONTENT_SAFETY_ENABLED=true to enable."
      exit
    end

    ContentSafetyJob.perform_now
    puts "Content safety scan complete!"
  end

  desc "Check a specific listing for safety (usage: rake safety:check_listing[LISTING_ID])"
  task :check_listing, [ :listing_id ] => :environment do |_t, args|
    listing_id = args[:listing_id]

    unless listing_id
      puts "Please provide a listing ID: rake safety:check_listing[123]"
      exit
    end

    listing = Listing.find_by(id: listing_id)

    unless listing
      puts "Listing ##{listing_id} not found"
      exit
    end

    puts "\nChecking Listing ##{listing.id}: #{listing.title}"
    puts "=" * 50

    safety_service = ContentSafetyService.new(listing)
    result = safety_service.check_safety

    if result[:safe]
      puts "✓ SAFE - This listing passed all safety checks"
    else
      puts "✗ UNSAFE - This listing failed safety checks"
      puts "Reason: #{result[:reason]}"
    end

    puts "=" * 50
  end
end
