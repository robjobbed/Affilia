# GitHub OAuth Setup Guide for Solomine

## 🎯 Complete Setup Checklist

### ✅ Step 1: Create GitHub OAuth App

1. **Go to GitHub Developer Settings**
   - Visit: https://github.com/settings/developers
   - Click "OAuth Apps" in the left sidebar
   - Click "New OAuth App"

2. **Fill in Application Details**
   ```
   Application name: Solomine
   Homepage URL: https://solomine.app
   Application description: Freelance marketplace for indie developers
   Authorization callback URL: solomine://auth/github/callback
   ```
   
   For development, you can create a separate OAuth app:
   ```
   Application name: Solomine (Development)
   Homepage URL: http://localhost:3000
   Authorization callback URL: solomine://auth/github/callback
   ```

3. **Save Your Credentials**
   - Copy the **Client ID** (e.g., `Ov23liABC123XYZ`)
   - Click "Generate a new client secret"
   - Copy the **Client Secret** immediately (you won't see it again!)
   
   ```
   Client ID: Ov23liABC123XYZ
   Client Secret: 1234567890abcdef1234567890abcdef12345678
   ```

### ✅ Step 2: Update iOS App Code

1. **Open `AuthenticationManager.swift`**

2. **Replace the placeholder Client ID**
   ```swift
   // Line ~305 - Find this line:
   let clientId = "YOUR_GITHUB_CLIENT_ID"
   
   // Replace with your actual Client ID:
   let clientId = "Ov23liABC123XYZ"  // Your actual Client ID from GitHub
   ```

### ✅ Step 3: Configure URL Scheme in Xcode

1. **Open your Xcode project**

2. **Select your target** (Solomine)

3. **Go to the "Info" tab**

4. **Scroll down to "URL Types"**
   - If it doesn't exist, add a new URL Type
   - Click the "+" button

5. **Add URL Scheme**
   ```
   Identifier: com.solomine.auth
   URL Schemes: solomine
   Role: Editor
   ```

6. **Verify the URL Scheme**
   Your Info.plist should contain:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLName</key>
           <string>com.solomine.auth</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>solomine</string>
           </array>
       </dict>
   </array>
   ```

### ✅ Step 4: Setup Backend Server

You'll need a backend server to exchange the OAuth code for an access token (GitHub doesn't allow this from mobile apps directly for security).

#### Option A: Node.js/Express Backend

Create a file: `backend/routes/github-auth.js`

```javascript
const express = require('express');
const axios = require('axios');
const router = express.Router();

// GitHub OAuth Config
const GITHUB_CLIENT_ID = 'YOUR_GITHUB_CLIENT_ID';
const GITHUB_CLIENT_SECRET = 'YOUR_GITHUB_CLIENT_SECRET';

// Exchange code for access token and fetch user profile
router.post('/api/auth/github/callback', async (req, res) => {
    const { code, redirect_uri } = req.body;
    
    try {
        // Step 1: Exchange code for access token
        const tokenResponse = await axios.post(
            'https://github.com/login/oauth/access_token',
            {
                client_id: GITHUB_CLIENT_ID,
                client_secret: GITHUB_CLIENT_SECRET,
                code: code,
                redirect_uri: redirect_uri
            },
            {
                headers: { Accept: 'application/json' }
            }
        );
        
        const accessToken = tokenResponse.data.access_token;
        
        // Step 2: Fetch user profile
        const userResponse = await axios.get('https://api.github.com/user', {
            headers: {
                Authorization: `Bearer ${accessToken}`,
                Accept: 'application/vnd.github.v3+json'
            }
        });
        
        const user = userResponse.data;
        
        // Step 3: Create your app's session token (JWT)
        // This is where you'd generate your own JWT token
        const appToken = generateJWT(user.id); // Implement this
        
        // Step 4: Return profile data to iOS app
        res.json({
            token: appToken,
            profile: {
                id: user.id.toString(),
                username: user.login,
                name: user.name,
                bio: user.bio,
                avatarURL: user.avatar_url,
                publicRepos: user.public_repos,
                followers: user.followers,
                following: user.following
            }
        });
        
    } catch (error) {
        console.error('GitHub OAuth error:', error);
        res.status(500).json({ error: 'GitHub authentication failed' });
    }
});

module.exports = router;
```

#### Option B: Quick Test with Local Server

For quick testing, you can use this simple Express server:

```javascript
// server.js
const express = require('express');
const axios = require('axios');
const app = express();

app.use(express.json());

const GITHUB_CLIENT_ID = 'YOUR_GITHUB_CLIENT_ID';
const GITHUB_CLIENT_SECRET = 'YOUR_GITHUB_CLIENT_SECRET';

app.post('/api/auth/github/callback', async (req, res) => {
    const { code } = req.body;
    
    try {
        // Exchange code for token
        const tokenResponse = await axios.post(
            'https://github.com/login/oauth/access_token',
            {
                client_id: GITHUB_CLIENT_ID,
                client_secret: GITHUB_CLIENT_SECRET,
                code: code
            },
            { headers: { Accept: 'application/json' } }
        );
        
        const accessToken = tokenResponse.data.access_token;
        
        // Get user data
        const userResponse = await axios.get('https://api.github.com/user', {
            headers: { Authorization: `Bearer ${accessToken}` }
        });
        
        const user = userResponse.data;
        
        res.json({
            token: 'test-token-' + user.id,
            profile: {
                id: user.id.toString(),
                username: user.login,
                name: user.name,
                bio: user.bio,
                avatarURL: user.avatar_url,
                publicRepos: user.public_repos,
                followers: user.followers,
                following: user.following
            }
        });
        
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed' });
    }
});

app.listen(3000, () => console.log('Server on http://localhost:3000'));
```

Run it:
```bash
npm install express axios
node server.js
```

### ✅ Step 5: Update Backend URL in iOS

In `AuthenticationManager.swift`, update the backend URL:

```swift
// For local development
let backendURL = "http://localhost:3000/api/auth/github/callback"

// For production (after deploying)
let backendURL = "https://api.solomine.app/api/auth/github/callback"
```

### ✅ Step 6: Test the Flow

1. **Run your iOS app**
2. **Tap "Link GitHub" button**
3. **You'll be redirected to GitHub**
4. **Authorize the app**
5. **You'll be redirected back to your app**
6. **Check the console for:**
   ```
   🔄 GitHub callback URL received: solomine://auth/github/callback?code=...
   ✅ GitHub authorization code received: abc123...
   🌐 Sending GitHub authorization code to backend...
   📡 GitHub backend response status: 200
   ✅ Successfully decoded GitHub profile from backend
   🔗 Linking GitHub profile to user...
   ✅ GitHub linking complete!
   ```

## 🔐 Security Best Practices

### ✅ Never Expose Client Secret in iOS App
- Client Secret should ONLY be on your backend server
- iOS app only sends the authorization code to your backend
- Backend exchanges code for token using Client Secret

### ✅ Use HTTPS in Production
```swift
// Production backend MUST use HTTPS
let backendURL = "https://api.solomine.app/api/auth/github/callback"
```

### ✅ Validate State Parameter
Add CSRF protection:
```swift
// Generate random state
let state = UUID().uuidString
// Save it
UserDefaults.standard.set(state, forKey: "github_oauth_state")

// Include in auth URL
let authURL = URL(string: "https://github.com/login/oauth/authorize?client_id=\(clientId)&state=\(state)...")

// Validate in callback
if let returnedState = components.queryItems?.first(where: { $0.name == "state" })?.value {
    let savedState = UserDefaults.standard.string(forKey: "github_oauth_state")
    guard returnedState == savedState else {
        // CSRF attack detected!
        return
    }
}
```

## 📝 Environment Variables

For managing secrets across environments:

### Development
```swift
#if DEBUG
let githubClientId = "Ov23liDEV_CLIENT_ID"
let backendURL = "http://localhost:3000"
#else
let githubClientId = "Ov23liPROD_CLIENT_ID"
let backendURL = "https://api.solomine.app"
#endif
```

## 🚀 Deployment Checklist

- [ ] Created GitHub OAuth App
- [ ] Saved Client ID and Client Secret securely
- [ ] Updated iOS app with Client ID
- [ ] Configured URL Scheme in Xcode (solomine://)
- [ ] Created backend endpoint
- [ ] Backend exchanges code for token
- [ ] Backend fetches GitHub profile
- [ ] Backend returns data to iOS
- [ ] Tested locally with mock data
- [ ] Tested with real GitHub OAuth flow
- [ ] Deployed backend to production
- [ ] Updated backend URL in iOS app
- [ ] Tested production flow

## 🐛 Troubleshooting

### Issue: "Invalid redirect_uri"
**Solution**: Make sure the callback URL in GitHub OAuth app settings exactly matches:
```
solomine://auth/github/callback
```

### Issue: "No callback received"
**Solution**: Check that URL scheme is properly configured in Info.plist

### Issue: "CORS error on backend"
**Solution**: Add CORS headers to your backend:
```javascript
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    next();
});
```

### Issue: "Backend returns 500"
**Solution**: Check that Client Secret is correct and token exchange is working

## 📚 Additional Resources

- [GitHub OAuth Documentation](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps)
- [GitHub API Documentation](https://docs.github.com/en/rest)
- [iOS URL Schemes Guide](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app)

## 💡 Next Steps

After GitHub is linked:
1. Display GitHub stats on builder profiles
2. Show top repositories in portfolio
3. Use GitHub activity for verification
4. Import README files as project descriptions
5. Analyze code languages from repos
