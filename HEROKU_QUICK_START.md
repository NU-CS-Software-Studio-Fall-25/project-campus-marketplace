# AI Feature - Heroku Deployment Quick Reference

## 🚀 Deploy Commands (Copy-Paste Ready)

### Set Your API Key
```bash
heroku config:set OPENAI_API_KEY=your-key-here --app your-app-name
```

### Recommended Cost Controls
```bash
# Conservative settings (max $2-3/month)
heroku config:set AI_DESCRIPTION_RATE_LIMIT=20 --app your-app-name
heroku config:set AI_DESCRIPTION_CACHE_DURATION=48 --app your-app-name
heroku config:set AI_DESCRIPTION_ENABLED=true --app your-app-name
```

### Optional: Add Redis (Free)
```bash
heroku addons:create heroku-redis:mini --app your-app-name
```

### Deploy
```bash
git add .
git commit -m "Add AI descriptions with cost controls"
git push heroku main
```

## 🎛️ Feature Controls

### Turn AI On/Off Instantly
```bash
# Disable (no cost)
heroku config:set AI_DESCRIPTION_ENABLED=false --app your-app-name

# Enable
heroku config:set AI_DESCRIPTION_ENABLED=true --app your-app-name
```

### Adjust Rate Limit
```bash
# Very conservative (max $1.50/month)
heroku config:set AI_DESCRIPTION_RATE_LIMIT=10 --app your-app-name

# Moderate (max $3/month)
heroku config:set AI_DESCRIPTION_RATE_LIMIT=20 --app your-app-name

# Higher (max $11/month)
heroku config:set AI_DESCRIPTION_RATE_LIMIT=100 --app your-app-name
```

## 💰 Cost Protection Built-In

✅ **Rate limiting** - Max generations per hour  
✅ **Caching** - Same image = $0 (no API call)  
✅ **Feature toggle** - Turn off anytime  
✅ **Graceful failure** - No AI key = manual entry works  

## 📊 Expected Costs

| Rate Limit | Max/Month | Typical/Month* |
|------------|-----------|----------------|
| 10/hour    | $1.50     | $0.60          |
| 20/hour    | $3.00     | $1.20          |
| 50/hour    | $7.50     | $3.00          |
| 100/hour   | $11.00    | $4.50          |

*Typical = 40% of max due to caching and user patterns

## 🔍 Monitor Usage

```bash
# Watch AI activity
heroku logs --tail --app your-app-name | grep "AI description"

# Check rate limits
heroku logs --tail --app your-app-name | grep "rate limit"
```

## 🚨 Emergency Shutoff

```bash
# If costs spike - instant disable
heroku config:set AI_DESCRIPTION_ENABLED=false --app your-app-name
```

## ✅ Post-Deployment Checklist

1. [ ] Set OPENAI_API_KEY on Heroku
2. [ ] Set AI_DESCRIPTION_RATE_LIMIT (start with 20)
3. [ ] Add Redis addon (optional but recommended)
4. [ ] Set OpenAI budget limit in dashboard ($5-10)
5. [ ] Deploy to Heroku
6. [ ] Test creating a listing with image
7. [ ] Monitor logs for first day
8. [ ] Check OpenAI usage after 24 hours

## 🎯 Recommended Starting Config

For a typical campus marketplace:

```bash
heroku config:set OPENAI_API_KEY=your-key-here --app your-app-name
heroku config:set AI_DESCRIPTION_RATE_LIMIT=20 --app your-app-name
heroku config:set AI_DESCRIPTION_ENABLED=true --app your-app-name
heroku addons:create heroku-redis:mini --app your-app-name
```

**Expected monthly cost: $1-2**

## 📈 Scale Up Later

Once you see usage patterns:
```bash
# If rate limit is hit often and budget allows
heroku config:set AI_DESCRIPTION_RATE_LIMIT=50 --app your-app-name
```

## Need Help?

- Check logs: `heroku logs --tail --app your-app-name`
- Full guide: See `HEROKU_DEPLOYMENT_GUIDE.md`
- OpenAI usage: https://platform.openai.com/usage
