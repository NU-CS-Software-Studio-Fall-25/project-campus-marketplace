# AI Image Description Feature

## Overview
This feature uses OpenAI's GPT-4 Vision API to automatically generate product descriptions when users upload images for their listings.

## Setup Instructions

### 1. Get an OpenAI API Key
1. Go to [OpenAI's platform](https://platform.openai.com/)
2. Sign up or log in
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key (you won't be able to see it again!)

### 2. Configure the API Key

You have two options:

#### Option A: Environment Variable (Recommended for Development)
Set the `OPENAI_API_KEY` environment variable:

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

#### Option B: Rails Credentials (Recommended for Production)
```bash
# Edit credentials
EDITOR="code --wait" rails credentials:edit

# Add this to the file:
openai:
  api_key: your-api-key-here
```

### 3. Restart Your Rails Server
After setting the API key, restart your Rails server for the changes to take effect.

## How It Works

1. **User uploads an image** in the listing form
2. **Direct upload** saves the image to Active Storage
3. **JavaScript triggers** the AI description generation
4. **Backend service** sends the image to OpenAI's GPT-4o-mini model
5. **AI analyzes** the image and generates a 2-3 sentence description
6. **Description auto-fills** in the form (user can edit it)
7. **User can regenerate** if they want a different description

## Features

- ✅ Automatic description generation on image upload
- ✅ Real-time status updates (loading, success, error)
- ✅ Regenerate button for getting alternative descriptions
- ✅ Fully editable AI-generated descriptions
- ✅ Graceful error handling (manual entry fallback)
- ✅ Optimized for campus marketplace items

## Cost Considerations

- Uses GPT-4o-mini model (cost-effective)
- Approximately $0.00015 per image analysis
- Set usage limits in OpenAI dashboard to control costs

## Testing Without API Key

If no API key is configured:
- The feature will fail gracefully
- Users see: "Could not generate description. Please enter manually."
- Manual description entry still works normally

## Troubleshooting

**"Could not generate description" error:**
- Check that OPENAI_API_KEY is set correctly
- Verify API key is valid in OpenAI dashboard
- Check Rails logs for detailed error messages

**Image upload but no description:**
- Check browser console for JavaScript errors
- Verify the route exists: `rails routes | grep generate_description`
- Ensure Stimulus controller is loaded

**Rate limiting:**
- OpenAI has rate limits on API calls
- Implement caching if needed for high traffic
