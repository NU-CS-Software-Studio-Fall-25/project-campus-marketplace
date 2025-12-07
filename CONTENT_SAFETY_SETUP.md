# Content Safety Feature

## Overview
This feature automatically detects and removes harmful listings from the Campus Marketplace. It uses AI-powered content moderation to identify prohibited items like drugs, alcohol, weapons, and other inappropriate content.

## How It Works

### 1. **Automatic Prevention (Real-time)**
When users create or edit listings, the system automatically checks for harmful content:
- **Text Analysis**: Scans title and description for prohibited keywords and uses OpenAI's Moderation API
- **Image Analysis**: Uses GPT-4 Vision to detect prohibited items in images
- **Immediate Blocking**: Unsafe listings are rejected before being published

### 2. **Background Monitoring**
A background job periodically scans existing listings:
- Checks all listings against current safety policies
- Automatically removes unsafe listings
- Sends email notifications to affected users

## Prohibited Content

The system checks for:
- 🚫 **Drugs & Controlled Substances**: Marijuana, pills, paraphernalia, etc.
- 🚫 **Alcohol**: Beer, wine, spirits (campus policy violation)
- 🚫 **Weapons**: Guns, knives, ammunition, explosives
- 🚫 **Counterfeit Goods**: Fake IDs, pirated content
- 🚫 **Stolen Items**: Items marked as stolen
- 🚫 **Other Harmful Content**: Violence, harassment, hate speech

## Setup Instructions

### 1. Enable the Feature

The feature is enabled by default. To disable it:

**Windows PowerShell:**
```powershell
$env:CONTENT_SAFETY_ENABLED = "false"
```

**Linux/Mac:**
```bash
export CONTENT_SAFETY_ENABLED=false
```

### 2. Configure OpenAI API Key

This feature uses the same OpenAI API key as the image description feature.

**Windows PowerShell:**
```powershell
$env:OPENAI_API_KEY = "your-api-key-here"
```

**Windows (Permanent):**
```powershell
[System.Environment]::SetEnvironmentVariable('OPENAI_API_KEY', 'your-api-key-here', 'User')
```

**Linux/Mac:**
```bash
export OPENAI_API_KEY="your-api-key-here"
```

### 3. Restart Your Rails Server
After setting environment variables, restart your Rails server.

## Running Safety Scans

### Manual Scan of All Listings
To scan all existing listings and remove unsafe ones:

```powershell
rails safety:scan
```

### Check a Specific Listing
To check if a specific listing is safe without removing it:

```powershell
rails safety:check_listing[123]
```
Replace `123` with the actual listing ID.

### Automated Periodic Scans
You can set up automated scans using cron jobs or a scheduler:

```ruby
# In config/schedule.rb (if using whenever gem)
every 1.day, at: '3:00 am' do
  rake 'safety:scan'
end
```

Or use a background job scheduler like Sidekiq with periodic jobs.

## User Experience

### When Creating a Listing
If a user tries to create a listing with prohibited content:
1. The form validation fails
2. An error message explains the issue
3. The listing is NOT created
4. User can modify and resubmit

### When a Listing is Removed
If an existing listing is flagged during a safety scan:
1. The listing is automatically deleted
2. The user receives an email notification
3. Email explains why it was removed
4. User can appeal if they believe it was a mistake

## Technical Details

### Service Architecture

**ContentSafetyService** (`app/services/content_safety_service.rb`)
- Main service for checking listing safety
- Uses multiple detection methods:
  - Keyword matching for obvious violations
  - OpenAI Moderation API for text content
  - GPT-4 Vision for image analysis
- Returns: `{ safe: true/false, reason: "..." }`

**ContentSafetyJob** (`app/jobs/content_safety_job.rb`)
- Background job for batch processing
- Scans all listings in database
- Removes unsafe listings
- Sends email notifications

**Listing Model Validation** (`app/models/listing.rb`)
- Custom validation: `content_safety_check`
- Runs on create and update
- Blocks save if content is unsafe

### Email Notifications

When a listing is removed, users receive:
- Subject: "Your listing was removed for safety reasons"
- Explanation of why it was removed
- Information about prohibited items
- Instructions for appealing

Template: `app/views/report_mailer/listing_removed_for_safety.html.erb`

## Configuration Options

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `CONTENT_SAFETY_ENABLED` | `true` | Enable/disable content safety checks |
| `OPENAI_API_KEY` | (required) | OpenAI API key for moderation |

## Cost Considerations

### OpenAI API Usage
- **Moderation API**: Free (no cost)
- **GPT-4 Vision**: ~$0.00015 per image
- Budget for scans: If scanning 1000 listings with images = ~$0.15

### Optimization Tips
1. Run scans during off-peak hours
2. Use rate limiting to avoid API throttling
3. Cache results to avoid duplicate checks
4. Implement incremental scanning (only new/modified listings)

## Troubleshooting

### "Safety check failed" errors when creating listings
**Cause**: Your listing contains prohibited content or keywords
**Solution**: Review your title, description, and image. Remove any references to drugs, alcohol, weapons, etc.

### Safety scan not running
**Check**: 
1. Is `CONTENT_SAFETY_ENABLED=true`?
2. Is OpenAI API key configured?
3. Check Rails logs for errors

### False positives (legitimate listings being flagged)
**Solution**:
1. Review the prohibited keywords in `ContentSafetyService`
2. Adjust sensitivity by modifying the keyword list
3. Users can appeal via email

### API rate limiting
**Cause**: Too many API calls in short time
**Solution**: 
1. Add delays between checks (already implemented: 0.5s per 10 listings)
2. Reduce scan frequency
3. Upgrade OpenAI API tier

## Testing Without OpenAI API Key

If no API key is configured:
- Keyword checking still works
- AI-based checks are skipped
- System logs warnings but doesn't crash
- Listings with obvious prohibited keywords are still blocked

## Security & Privacy

- **No data retention**: Images and text are not stored by OpenAI (per their API policy)
- **Private scanning**: All checks happen server-side
- **User privacy**: Only flagged content is logged
- **Appeal process**: Users can contact admins if they believe removal was in error

## Monitoring & Logs

Check Rails logs for:
- Safety check results: `ContentSafetyService`
- Job executions: `ContentSafetyJob`
- Removals: `Removing unsafe listing #ID: reason`
- Errors: `ContentSafetyService error: ...`

```powershell
# View recent logs
Get-Content log\development.log -Tail 100
```

## Best Practices

1. **Run initial scan**: After enabling, run a full scan to clean existing listings
2. **Regular scans**: Schedule weekly or daily scans
3. **Monitor logs**: Check for patterns in flagged content
4. **Update keywords**: Add new prohibited terms as needed
5. **User education**: Clearly communicate policies to users

## Support

For issues or questions:
1. Check Rails logs for detailed error messages
2. Verify OpenAI API key is valid
3. Test with `rails safety:check_listing[ID]`
4. Review prohibited keyword list

## Future Enhancements

Potential improvements:
- [ ] Machine learning model for campus-specific items
- [ ] Confidence scores for flagged content
- [ ] User reputation system
- [ ] Automated appeal review process
- [ ] Dashboard for monitoring safety metrics
- [ ] Whitelist for verified sellers
