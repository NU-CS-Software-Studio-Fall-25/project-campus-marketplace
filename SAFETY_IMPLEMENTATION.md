# Automatic Harmful Listing Removal - Implementation Summary

## Overview
Implemented a comprehensive content safety system that automatically detects and removes harmful listings from the Campus Marketplace using AI-powered moderation.

## Files Created

### Core Services
1. **`app/services/content_safety_service.rb`**
   - Main service for detecting harmful content
   - Uses OpenAI Moderation API for text analysis
   - Uses GPT-4 Vision for image analysis
   - Keyword-based detection for obvious violations
   - Returns safety status and reasons

### Background Jobs
2. **`app/jobs/content_safety_job.rb`**
   - Batch processes all listings in database
   - Automatically removes unsafe listings
   - Sends email notifications to affected users
   - Rate-limited to avoid API throttling

### Email Templates
3. **`app/views/report_mailer/listing_removed_for_safety.html.erb`**
   - Professional email template for removal notifications
   - Explains removal reason
   - Lists prohibited items
   - Provides appeal process

### Rake Tasks
4. **`lib/tasks/safety.rake`**
   - `rails safety:scan` - Scan all listings and remove unsafe ones
   - `rails safety:check_listing[ID]` - Check specific listing without removing

### Documentation
5. **`CONTENT_SAFETY_SETUP.md`**
   - Comprehensive setup guide
   - Technical documentation
   - Troubleshooting guide
   - Best practices

6. **`SAFETY_QUICK_START.md`**
   - Quick start guide for users
   - Common questions and answers
   - Simple setup instructions

## Files Modified

### Models
1. **`app/models/listing.rb`**
   - Added `content_safety_check` validation
   - Runs on create and update
   - Blocks unsafe listings before saving
   - Provides clear error messages

### Mailers
2. **`app/mailers/report_mailer.rb`**
   - Added `listing_removed_for_safety` method
   - Sends notifications to affected users

### Configuration
3. **`config/application.rb`**
   - Added `content_safety_enabled` config (default: true)
   - Centralized configuration management

## How It Works

### Real-time Prevention (Create/Edit)
```
User creates listing
    ↓
Listing model validation
    ↓
ContentSafetyService checks:
  - Keyword matching (drugs, alcohol, weapons)
  - OpenAI Moderation API (text)
  - GPT-4 Vision (image)
    ↓
If unsafe → Validation fails → Error shown to user
If safe → Listing saved
```

### Background Monitoring (Existing Listings)
```
Run: rails safety:scan
    ↓
ContentSafetyJob starts
    ↓
For each listing:
  - Check with ContentSafetyService
  - If unsafe → Delete + Email user
  - If safe → Continue
    ↓
Log results
```

## Detection Methods

### 1. Keyword Matching (Fast, Free)
Scans for prohibited terms:
- Drugs: marijuana, pills, cocaine, etc.
- Alcohol: beer, wine, vodka, etc.
- Weapons: gun, knife, ammunition, etc.
- Other: fake ID, stolen, counterfeit, etc.

### 2. OpenAI Moderation API (Text, Free)
Detects:
- Violence
- Hate speech
- Harassment
- Self-harm
- Sexual content
- Illegal activities

### 3. GPT-4 Vision (Images, Paid)
Analyzes images for:
- Drugs and paraphernalia
- Alcohol bottles/cans
- Weapons
- Other prohibited items

## Configuration

### Enable/Disable
```powershell
# Enable (default)
$env:CONTENT_SAFETY_ENABLED = "true"

# Disable
$env:CONTENT_SAFETY_ENABLED = "false"
```

### Required API Key
```powershell
$env:OPENAI_API_KEY = "your-key-here"
```

## Usage

### For New Listings
Automatic - no action needed. Users will see validation errors if they try to post harmful content.

### For Existing Listings
```powershell
# Scan all listings
rails safety:scan

# Check specific listing
rails safety:check_listing[123]
```

### For Scheduled Scanning
Set up a cron job or background scheduler:
```ruby
# Run daily at 3 AM
every 1.day, at: '3:00 am' do
  rake 'safety:scan'
end
```

## User Experience

### Creating an Unsafe Listing
1. User fills out form with prohibited content
2. Clicks "Create Listing"
3. Validation fails
4. Error message: "This listing cannot be published: Contains prohibited keyword: marijuana. Please ensure your listing does not contain prohibited items..."
5. User can edit and resubmit

### Existing Listing Removed
1. Background job detects unsafe content
2. Listing is deleted from database
3. User receives email notification
4. Email explains reason and provides appeal process

## Error Handling

- **API failures**: System fails open (allows listing) to avoid blocking legitimate content
- **Rate limiting**: Built-in delays (0.5s per 10 listings)
- **Missing API key**: Keyword checking still works
- **Invalid listings**: Logged but job continues

## Cost Estimate

### Free Components
- Keyword matching: $0
- OpenAI Moderation API: $0

### Paid Components
- GPT-4 Vision: ~$0.00015 per image
- Example: 1000 listings = ~$0.15

## Testing

### Manual Testing
1. Try creating a listing with "beer" in the title
2. Should be blocked with clear error message

### Check Existing Listing
```powershell
rails safety:check_listing[123]
```

### Run Full Scan (Test Mode)
```powershell
# Enable safety checks
$env:CONTENT_SAFETY_ENABLED = "true"

# Run scan
rails safety:scan
```

## Monitoring

Check logs for:
- Safety check results
- Removed listings
- API errors
- User notifications

```powershell
Get-Content log\development.log -Tail 100 | Select-String "ContentSafety"
```

## Customization

### Add More Keywords
Edit `app/services/content_safety_service.rb`:
```ruby
PROHIBITED_KEYWORDS = [
  # Add your keywords here
  "new_prohibited_term",
  # ...
]
```

### Adjust Sensitivity
Modify the detection thresholds or prompt in `ContentSafetyService`

### Custom Email Template
Edit `app/views/report_mailer/listing_removed_for_safety.html.erb`

## Security Features

✅ Multiple detection layers (keyword + AI)
✅ Both text and image analysis
✅ Real-time prevention + background monitoring
✅ User notifications with appeal process
✅ Configurable (can be disabled if needed)
✅ Fail-safe design (errors don't break site)
✅ Rate limiting to prevent abuse
✅ Privacy-respecting (no data retention by OpenAI)

## Next Steps

1. **Set OpenAI API key** if not already set
2. **Run initial scan**: `rails safety:scan`
3. **Test with sample listings** containing prohibited terms
4. **Set up scheduled scans** for ongoing monitoring
5. **Monitor logs** for the first few days
6. **Adjust keywords** based on your campus policies

## Support

- Quick Start: See `SAFETY_QUICK_START.md`
- Full Documentation: See `CONTENT_SAFETY_SETUP.md`
- Code: `app/services/content_safety_service.rb`
- Tests: Use `rails safety:check_listing[ID]`

---

**Status**: ✅ Fully Implemented and Ready to Use
**Version**: 1.0
**Date**: December 2025
