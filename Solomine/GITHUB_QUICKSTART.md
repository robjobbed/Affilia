# 🚀 GitHub OAuth Quick Start

Follow these steps to get GitHub OAuth working in your Solomine app in ~10 minutes.

## ⏱️ Quick Setup (10 minutes)

### 1️⃣ Create GitHub OAuth App (3 minutes)

1. Go to: https://github.com/settings/developers
2. Click "OAuth Apps" → "New OAuth App"
3. Fill in:
   - **Application name**: `Solomine Dev`
   - **Homepage URL**: `http://localhost:3000`
   - **Callback URL**: `solomine://auth/github/callback`
4. Click "Register application"
5. Copy your **Client ID** (looks like `Ov23liABC123XYZ`)
6. Click "Generate a new client secret" and copy it immediately

✅ **You should now have:**
```
Client ID: Ov23liABC123XYZ
Client Secret: 1234567890abcdef1234567890abcdef12345678
```

### 2️⃣ Setup Backend Server (2 minutes)

1. Open Terminal and navigate to the backend folder:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Open `github-oauth-server.js` and update these lines:
```javascript
const GITHUB_CLIENT_ID = 'Ov23liABC123XYZ';  // Your Client ID
const GITHUB_CLIENT_SECRET = 'your_client_secret_here';  // Your Client Secret
```

4. Start the server:
```bash
npm start
```

You should see:
```
🚀 Solomine GitHub OAuth Server
================================
✅ Server running on http://localhost:3000
```

✅ **Backend is ready!**

### 3️⃣ Configure iOS App (2 minutes)

1. Open `AuthenticationManager.swift`

2. Find line ~305 and update:
```swift
let clientId = "Ov23liABC123XYZ"  // Your GitHub Client ID
```

3. In Xcode, select your **Solomine** target

4. Go to **Info** tab

5. Scroll to **URL Types** section

6. If "solomine" isn't there, click **+** and add:
   - **Identifier**: `com.solomine.auth`
   - **URL Schemes**: `solomine`
   - **Role**: `Editor`

✅ **iOS app is configured!**

### 4️⃣ Test It! (3 minutes)

1. Make sure backend server is still running:
```bash
cd backend
npm start
```

2. Run your iOS app in Xcode (⌘R)

3. Navigate to where you have the "Link GitHub" button
   - Could be in profile settings
   - Or create a test button somewhere

4. Tap "Link GitHub"

5. You should see:
   - GitHub authorization page opens in Safari
   - Login if needed
   - Click "Authorize"
   - Redirects back to your app
   - ✅ GitHub profile linked!

6. Check Xcode console for:
```
🔄 GitHub callback URL received: solomine://auth/github/callback?code=...
✅ GitHub authorization code received: abc123...
🌐 Sending GitHub authorization code to backend...
📡 GitHub backend response status: 200
✅ Successfully decoded GitHub profile from backend
🔗 Linking GitHub profile to user...
   - Username: @your_username
   - Public Repos: 42
✅ GitHub linking complete!
```

7. Check backend terminal for:
```
📥 Received GitHub OAuth callback
🔄 Exchanging code for access token...
✅ Got access token: ghp_abc123...
👤 Fetching GitHub user profile...
✅ Got GitHub user: your_username
   Name: Your Name
   Public Repos: 42
   Followers: 123
✅ Sending profile to iOS app
```

## ✅ Success!

Your GitHub OAuth is now working! 🎉

## 🎯 What's Next?

### Display GitHub Profile in App

```swift
// In your profile view:
if let github = authManager.githubProfile {
    VStack(alignment: .leading) {
        Text("GitHub: @\(github.username)")
        Text("\(github.publicRepos) public repos")
        Text("\(github.followers) followers")
    }
}
```

### Show GitHub Avatar

```swift
if let avatarURL = authManager.githubProfile?.avatarURL {
    AsyncImage(url: URL(string: avatarURL)) { image in
        image.resizable()
            .scaledToFill()
    } placeholder: {
        ProgressView()
    }
    .frame(width: 60, height: 60)
    .clipShape(Circle())
}
```

### Fetch User's Repositories

Add this to your backend:

```javascript
// Fetch user's repos
const reposResponse = await axios.get('https://api.github.com/user/repos', {
    headers: {
        Authorization: `Bearer ${accessToken}`,
        Accept: 'application/vnd.github.v3+json'
    },
    params: {
        sort: 'updated',
        per_page: 10
    }
});

response.repos = reposResponse.data.map(repo => ({
    name: repo.name,
    description: repo.description,
    stars: repo.stargazers_count,
    language: repo.language,
    url: repo.html_url
}));
```

## 🐛 Troubleshooting

### "No callback received"
- Check URL scheme in Xcode Info.plist
- Make sure it's `solomine` (lowercase)

### "Backend 500 error"
- Check Client Secret is correct
- Check backend logs for specific error

### "Invalid redirect_uri"
- Callback URL in GitHub must be exactly: `solomine://auth/github/callback`
- Check for typos

### Backend not running
```bash
cd backend
npm start
```

### Port 3000 already in use
```bash
# Kill the process using port 3000
lsof -ti:3000 | xargs kill -9

# Or change the port in github-oauth-server.js:
const PORT = 3001;  // Use different port
```

## 📚 Files Created

- ✅ `AuthenticationManager.swift` - Updated with GitHub OAuth
- ✅ `backend/github-oauth-server.js` - OAuth server
- ✅ `backend/package.json` - Dependencies
- ✅ `GITHUB_OAUTH_SETUP.md` - Full documentation

## 🔐 Security Notes

⚠️ **NEVER commit your Client Secret to git!**

Create a `.env` file:
```bash
GITHUB_CLIENT_ID=your_client_id
GITHUB_CLIENT_SECRET=your_client_secret
```

Add to `.gitignore`:
```
.env
backend/.env
```

Update server to use environment variables:
```javascript
require('dotenv').config();
const GITHUB_CLIENT_ID = process.env.GITHUB_CLIENT_ID;
const GITHUB_CLIENT_SECRET = process.env.GITHUB_CLIENT_SECRET;
```

## 🚀 Production Deployment

When ready for production:

1. Deploy backend to:
   - Heroku
   - Vercel
   - Railway
   - Your own server

2. Update iOS app:
```swift
#if DEBUG
let backendURL = "http://localhost:3000/api/auth/github/callback"
#else
let backendURL = "https://api.solomine.app/api/auth/github/callback"
#endif
```

3. Create production GitHub OAuth app with:
   - Homepage URL: `https://solomine.app`
   - Callback URL: `solomine://auth/github/callback`

That's it! You're ready to link GitHub accounts! 🎉
