# Testing the Content Safety Feature

## Quick Test Commands

### 1. Check if a listing is safe
```powershell
rails safety:check_listing[1]
```

### 2. Scan all listings (dry run - see what would be removed)
```powershell
# First, check your logs to see what would happen
rails runner "
listings = Listing.all
puts 'Total listings: ' + listings.count.to_s
puts ''
listings.each do |listing|
  service = ContentSafetyService.new(listing)
  result = service.check_safety
  status = result[:safe] ? '✓ SAFE' : '✗ UNSAFE'
  puts \"Listing #\#{listing.id}: \#{listing.title} - \#{status}\"
  puts \"  Reason: \#{result[:reason]}\" unless result[:safe]
end
"
```

### 3. Actually scan and remove unsafe listings
```powershell
rails safety:scan
```

## Test with Sample Listings

### Test 1: Create a listing with prohibited keywords (should be blocked)
```powershell
rails console
```

Then in the console:
```ruby
user = User.first
listing = user.listings.build(
  title: "Beer for sale",
  description: "Selling cold beer",
  price: 10,
  category: "other"
)
# Try to attach an image first, then save
listing.save
# Should fail with error about prohibited content
puts listing.errors.full_messages
```

### Test 2: Create a safe listing (should work)
```ruby
listing = user.listings.build(
  title: "Calculus Textbook",
  description: "Barely used textbook in great condition",
  price: 40,
  category: "other"
)
# Attach an image, then save
listing.save
# Should succeed
```

## Understanding the Results

### Safe Listing Output
```
✓ SAFE - This listing passed all safety checks
```

### Unsafe Listing Output
```
✗ UNSAFE - This listing failed safety checks
Reason: Contains prohibited keyword: beer
```

## Check Configuration

```powershell
rails runner "
puts 'Content Safety Enabled: ' + Rails.application.config.content_safety_enabled.to_s
puts 'AI Description Enabled: ' + Rails.application.config.ai_description_enabled.to_s
puts 'OpenAI API Key Set: ' + (ENV['OPENAI_API_KEY'].present?).to_s
"
```

## Monitoring Logs

Watch for safety-related log entries:
```powershell
# Follow logs in real-time
Get-Content log\development.log -Wait -Tail 50 | Select-String "ContentSafety|safety"
```

## Common Test Scenarios

### Scenario 1: Prohibited Keyword in Title
- Title: "Marijuana for sale"
- Expected: UNSAFE - Contains prohibited keyword

### Scenario 2: Prohibited Keyword in Description
- Description: "This vodka bottle is great"
- Expected: UNSAFE - Contains prohibited keyword

### Scenario 3: Normal Listing
- Title: "Desk Lamp"
- Description: "LED desk lamp in perfect condition"
- Expected: SAFE

### Scenario 4: Edge Case - Similar Words
- Title: "Gundam Action Figure"
- Description: "Cool robot figure"
- Expected: May be flagged due to "gun" in "Gundam" - this is a known edge case

## Customizing Detection

If you get false positives (legitimate items being flagged), you can:

1. **Adjust keyword matching** in `app/services/content_safety_service.rb`:
   - Make keywords more specific
   - Add word boundary checks
   - Use whole-word matching instead of substring matching

2. **Update the prohibited keywords list**:
   - Remove overly broad terms
   - Add more specific terms

Example fix for "Gundam" false positive:
```ruby
# In ContentSafetyService, change keyword matching to:
prohibited_match = PROHIBITED_KEYWORDS.find do |keyword|
  content.match?(/\b#{Regexp.escape(keyword)}\b/i)
end
```

## Troubleshooting

### Issue: All listings pass safety check
**Possible causes**:
1. Content safety is disabled
2. No OpenAI API key set (keyword checking still works)
3. Listings don't contain prohibited content

**Check**:
```powershell
rails runner "puts Rails.application.config.content_safety_enabled"
```

### Issue: Safety scan doesn't remove anything
**Possible causes**:
1. All listings are actually safe
2. Feature is disabled

**Solution**: Try creating a test listing with "beer" in the title first

### Issue: Cannot create any listings
**Possible cause**: Safety check is too strict or API is down

**Temporary fix**:
```powershell
$env:CONTENT_SAFETY_ENABLED = "false"
# Restart server
```

## Performance Testing

Test how long safety checks take:
```powershell
rails runner "
require 'benchmark'
user = User.first
listing = user.listings.first || user.listings.build(title: 'Test', description: 'Test item', price: 10, category: 'other')

time = Benchmark.measure {
  service = ContentSafetyService.new(listing)
  result = service.check_safety
  puts result.inspect
}
puts 'Time taken: ' + time.real.round(2).to_s + ' seconds'
"
```

## Next Steps After Testing

1. ✅ Verify the feature works with test listings
2. ✅ Run a full scan on your database
3. ✅ Check logs for any errors
4. ✅ Set up scheduled scans (cron job or scheduler)
5. ✅ Monitor for false positives
6. ✅ Adjust keywords if needed
7. ✅ Document your campus-specific policies

---

Need help? See `CONTENT_SAFETY_SETUP.md` for detailed documentation.
