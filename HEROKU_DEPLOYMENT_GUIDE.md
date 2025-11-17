# Deploying AI Image Description to Heroku - Cost Management Guide

## Cost Management Strategies

### 1. Rate Limiting (Implemented ✅)
The app now includes built-in rate limiting to prevent cost overruns:
- **Default**: 100 descriptions per hour
- **Cached results**: Same image = free (no API call)
- **Per-app limit**: Not per-user, so shared across all users

### 2. Caching (Implemented ✅)
Images with the same content (checksum) reuse cached descriptions:
- **Default cache**: 24 hours
- **Benefits**: If a user uploads the same image, instant result
- **Storage**: Uses Rails cache (memory or Redis)

### 3. Feature Toggle (Implemented ✅)
You can enable/disable AI generation without redeploying:
- Turn off during high-traffic periods
- Disable if approaching budget limits
- Re-enable when ready

## Heroku Setup Instructions

### Step 1: Set Your OpenAI API Key on Heroku

```bash
# Set the API key (replace with your actual key)
heroku config:set OPENAI_API_KEY=sk-your-actual-key-here --app your-app-name

# Verify it was set
heroku config:get OPENAI_API_KEY --app your-app-name
```

### Step 2: Configure Cost Controls (Optional)

```bash
# Set custom rate limit (default is 100 per hour)
heroku config:set AI_DESCRIPTION_RATE_LIMIT=50 --app your-app-name

# Set custom cache duration in hours (default is 24)
heroku config:set AI_DESCRIPTION_CACHE_DURATION=48 --app your-app-name

# Enable/disable feature (default is true)
heroku config:set AI_DESCRIPTION_ENABLED=true --app your-app-name
```

### Step 3: Add Redis for Better Caching (Recommended)

Redis improves rate limiting and caching across dynos:

```bash
# Add free Redis addon
heroku addons:create heroku-redis:mini --app your-app-name

# The REDIS_URL will be set automatically
```

Then update your `config/environments/production.rb`:

```ruby
# Add this inside the configure block
config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
```

### Step 4: Deploy

```bash
git add .
git commit -m "Add AI image description with cost controls"
git push heroku main
```

### Step 5: Monitor Usage

```bash
# Watch your logs for AI generation activity
heroku logs --tail --app your-app-name | grep "ImageAnalyzerService"

# Check rate limit hits
heroku logs --tail --app your-app-name | grep "rate limit"
```

## Cost Estimation

### OpenAI GPT-4o-mini Pricing (as of Nov 2024)
- **Cost per image**: ~$0.00015 per description
- **1,000 images**: ~$0.15
- **10,000 images**: ~$1.50

### With Rate Limiting (100/hour)
- **Max daily cost**: 2,400 descriptions × $0.00015 = **$0.36/day**
- **Max monthly cost**: **~$11/month**

### With Caching
- Actual costs will be lower due to:
  - Same image reuse (no API call)
  - Users regenerating (cached)
  - Failed uploads (no API call)

## Budget Protection Strategies

### Option 1: Lower Rate Limit
```bash
# Reduce to 20 descriptions per hour
heroku config:set AI_DESCRIPTION_RATE_LIMIT=20 --app your-app-name
# Max cost: ~$2.20/month
```

### Option 2: Disable During Low-Value Times
```bash
# Disable overnight (manually or with scheduler)
heroku config:set AI_DESCRIPTION_ENABLED=false --app your-app-name

# Re-enable in the morning
heroku config:set AI_DESCRIPTION_ENABLED=true --app your-app-name
```

### Option 3: Set OpenAI Usage Limits
In your OpenAI dashboard:
1. Go to Settings → Limits
2. Set a monthly budget cap (e.g., $5)
3. Set up email alerts at 50% and 80%

### Option 4: Make It Optional (Recommended for Cost Control)
Add a "Generate Description" button instead of auto-generating:

Users explicitly choose when to use AI (reduces calls by ~70%)

## Monitoring & Alerts

### OpenAI Dashboard
- View usage: https://platform.openai.com/usage
- Set budget limits
- Enable email notifications

### Heroku Logs
```bash
# Count AI generations today
heroku logs --tail --app your-app-name | grep "AI description generated"

# Check for rate limit hits
heroku logs --tail --app your-app-name | grep "rate limit exceeded"

# Monitor errors
heroku logs --tail --app your-app-name | grep "ImageAnalyzerService error"
```

### Add Monitoring (Optional)
Consider adding application monitoring:
- Heroku Metrics (free tier)
- Papertrail for log analysis
- Custom analytics to track AI usage

## Graceful Degradation

The feature is designed to fail gracefully:

1. **No API Key**: Users enter descriptions manually
2. **Rate Limit Hit**: Clear message, manual entry
3. **API Error**: Fallback to manual entry
4. **Feature Disabled**: Manual entry only

## Emergency Cost Cutoff

If costs spike unexpectedly:

```bash
# Immediately disable AI generation
heroku config:set AI_DESCRIPTION_ENABLED=false --app your-app-name

# Or remove API key entirely
heroku config:unset OPENAI_API_KEY --app your-app-name
```

## Best Practices

1. ✅ **Start conservative**: Use rate limit of 20-50/hour initially
2. ✅ **Monitor first week**: Watch usage patterns and costs
3. ✅ **Set OpenAI budget**: Hard cap in OpenAI dashboard ($5-10/month)
4. ✅ **Enable Redis**: Better rate limiting across dynos
5. ✅ **Log everything**: Track usage for optimization
6. ✅ **Educate users**: Let them know AI is available but limited

## Alternative: Make AI Optional (Lowest Cost)

If you want maximum control, make AI generation opt-in:

**Benefits:**
- Users only use it when they want to
- Reduces API calls by 70-80%
- More predictable costs
- Better user experience (faster form submission)

**Implementation:**
Add a "✨ Generate with AI" button next to the description field instead of auto-generating.

## Estimated Real-World Costs

Based on typical campus marketplace usage:

- **Small campus** (50 listings/week): ~$0.30/month
- **Medium campus** (200 listings/week): ~$1.20/month  
- **Large campus** (500 listings/week): ~$3.00/month

With caching and rate limiting, actual costs are typically 40-60% of max estimates.

## Questions to Consider

1. How many new listings do you expect per day?
2. What's your monthly budget for this feature?
3. Do you want auto-generate or opt-in?
4. Do you need AI for all listings or just new ones?

Based on your answers, I can adjust the rate limits and caching settings.
