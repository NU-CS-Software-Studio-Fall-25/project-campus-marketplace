# Quick Start: Automatic Harmful Listing Removal

Your Campus Marketplace now automatically removes harmful listings! 🛡️

## What Gets Removed?

Listings with:
- Drugs or controlled substances
- Alcohol
- Weapons
- Counterfeit or stolen goods
- Other inappropriate content

## How to Enable (Quick Steps)

1. **Set your OpenAI API key** (if you haven't already):
   ```powershell
   $env:OPENAI_API_KEY = "your-api-key-here"
   ```

2. **Restart your Rails server**

That's it! The feature is enabled by default.

## What Happens Now?

### For New Listings
- ✅ When users create listings, they're automatically checked
- ❌ Harmful listings are blocked before being published
- 📧 Users see a clear error message

### For Existing Listings
Run this command to scan and remove unsafe listings:
```powershell
rails safety:scan
```

### User Notifications
- Users receive an email when their listing is removed
- Email explains why it was removed
- Users can appeal if they think it's a mistake

## Check a Specific Listing

To test if a listing would be flagged:
```powershell
rails safety:check_listing[123]
```
(Replace 123 with the listing ID)

## Disable the Feature

If you want to turn it off:
```powershell
$env:CONTENT_SAFETY_ENABLED = "false"
```

## Need More Details?

See the full documentation: `CONTENT_SAFETY_SETUP.md`

## Common Questions

**Q: Does this cost money?**
A: OpenAI's Moderation API is free. Image analysis costs about $0.00015 per image.

**Q: What if a legitimate listing gets flagged?**
A: Users can reply to the removal email to appeal. You can manually review using `rails safety:check_listing[ID]`

**Q: Can I customize what gets flagged?**
A: Yes! Edit the keyword list in `app/services/content_safety_service.rb`

**Q: Will this slow down my site?**
A: No. Validation runs during form submission (users already wait). Background scans run separately.

---

For technical details, troubleshooting, and advanced configuration, see `CONTENT_SAFETY_SETUP.md`
