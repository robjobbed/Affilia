# Affilia Backend - GitHub OAuth Server

Simple Express server to handle GitHub OAuth for the Affilia iOS app.

## Quick Start

```bash
# Install dependencies
npm install

# Update credentials in github-oauth-server.js
# Replace YOUR_GITHUB_CLIENT_ID and YOUR_GITHUB_CLIENT_SECRET

# Start server
npm start
```

Server runs on `http://localhost:3000`

## Endpoints

### GET /
Health check endpoint

Response:
```json
{
  "status": "Affilia GitHub OAuth Server",
  "version": "1.0.0"
}
```

### POST /api/auth/github/callback
Exchanges GitHub authorization code for access token and user profile.

Request:
```json
{
  "code": "authorization_code_from_github",
  "redirect_uri": "affilia://auth/github/callback"
}
```

Response:
```json
{
  "token": "your_app_session_token",
  "profile": {
    "id": "12345",
    "username": "robcodes",
    "name": "Rob Behbahani",
    "bio": "Full-stack developer",
    "avatarURL": "https://avatars.githubusercontent.com/u/12345",
    "publicRepos": 42,
    "followers": 234,
    "following": 89
  }
}
```

## Environment Variables

For production, use environment variables:

Create `.env` file:
```
GITHUB_CLIENT_ID=your_client_id_here
GITHUB_CLIENT_SECRET=your_client_secret_here
PORT=3000
```

Install dotenv:
```bash
npm install dotenv
```

Update server:
```javascript
require('dotenv').config();
const GITHUB_CLIENT_ID = process.env.GITHUB_CLIENT_ID;
const GITHUB_CLIENT_SECRET = process.env.GITHUB_CLIENT_SECRET;
const PORT = process.env.PORT || 3000;
```

## Production Deployment

### Option 1: Heroku
```bash
heroku create affilia-api
heroku config:set GITHUB_CLIENT_ID=your_id
heroku config:set GITHUB_CLIENT_SECRET=your_secret
git push heroku main
```

### Option 2: Railway
1. Create new project on railway.app
2. Connect GitHub repo
3. Add environment variables
4. Deploy

### Option 3: Vercel
```bash
vercel
vercel env add GITHUB_CLIENT_ID
vercel env add GITHUB_CLIENT_SECRET
vercel --prod
```

## Security

⚠️ **Never commit secrets to git!**

Add to `.gitignore`:
```
.env
node_modules/
.DS_Store
```

## Development

Watch mode (auto-restart on changes):
```bash
npm run dev
```

## License

MIT
