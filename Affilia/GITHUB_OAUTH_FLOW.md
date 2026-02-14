# GitHub OAuth Flow Diagram

## 🔄 Complete OAuth Flow

```
┌─────────────┐                                    ┌──────────────┐
│             │                                    │              │
│  iOS App    │                                    │   GitHub     │
│ (Affilia)  │                                    │   OAuth      │
│             │                                    │              │
└──────┬──────┘                                    └──────┬───────┘
       │                                                  │
       │ 1. User taps "Link GitHub"                      │
       │    authManager.linkGitHub()                     │
       │                                                  │
       │ 2. Open Safari with authorization URL           │
       │    https://github.com/login/oauth/authorize     │
       │    ?client_id=Ov23liABC123XYZ                   │
       │    &redirect_uri=affilia://auth/github/callback│
       │    &scope=user:email read:user                  │
       ├─────────────────────────────────────────────────>│
       │                                                  │
       │                                                  │ 3. User logs in
       │                                                  │    and authorizes
       │                                                  │
       │ 4. GitHub redirects to callback URL             │
       │    affilia://auth/github/callback              │
       │    ?code=abc123def456                           │
       │<─────────────────────────────────────────────────┤
       │                                                  │
       │ 5. handleGitHubCallback(url:)                   │
       │    Extracts authorization code                  │
       │                                                  │
       │                                                  │
       │         ┌──────────────┐                        │
       │         │              │                        │
       │    6.   │   Backend    │                        │
       │ POST    │   Server     │                        │
       │ code    │ (localhost)  │                        │
       ├────────>│              │                        │
       │         │              │  7. Exchange code      │
       │         │              │     for access token   │
       │         │              ├───────────────────────>│
       │         │              │                        │
       │         │              │  8. Return token       │
       │         │              │     access_token=ghu_  │
       │         │              │<───────────────────────┤
       │         │              │                        │
       │         │              │  9. Fetch user profile │
       │         │              │     GET /user          │
       │         │              │     Authorization: ... │
       │         │              ├───────────────────────>│
       │         │              │                        │
       │         │              │ 10. Return user data   │
       │         │              │     {login, repos...}  │
       │         │              │<───────────────────────┤
       │         │              │                        │
       │  11.    │              │                        │
       │ Return  │              │                        │
       │ profile │              │                        │
       │<────────┤              │                        │
       │         └──────────────┘                        │
       │                                                  │
       │ 12. linkGitHubProfile()                         │
       │     Store profile in authManager                │
       │     Update UI                                   │
       │                                                  │
```

## 📱 Detailed Steps

### Step 1-2: Initiate OAuth
```swift
// iOS App
func linkGitHub() {
    let clientId = "Ov23liABC123XYZ"
    let redirectURI = "affilia://auth/github/callback"
    let authURL = URL(string: 
        "https://github.com/login/oauth/authorize" +
        "?client_id=\(clientId)" +
        "&redirect_uri=\(redirectURI)" +
        "&scope=user:email read:user"
    )!
    
    authSession = ASWebAuthenticationSession(
        url: authURL,
        callbackURLScheme: "affilia"
    ) { callbackURL, error in
        self.handleGitHubCallback(url: callbackURL)
    }
    
    authSession?.start()
}
```

### Step 3: User Authorizes
- Safari opens with GitHub login
- User logs in (if not already)
- Sees authorization screen:
  ```
  Affilia would like permission to:
  ✓ Read your email addresses
  ✓ Read your profile information
  
  [Authorize Affilia]  [Cancel]
  ```

### Step 4: GitHub Redirects
```
affilia://auth/github/callback?code=abc123def456ghi789
```

### Step 5: Extract Code
```swift
// iOS App
private func handleGitHubCallback(url: URL) {
    let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    
    guard let code = components.queryItems?
        .first(where: { $0.name == "code" })?.value else {
        return
    }
    
    // code = "abc123def456ghi789"
    exchangeGitHubCodeForProfile(code: code)
}
```

### Step 6: Send to Backend
```swift
// iOS App
private func exchangeGitHubCodeForProfile(code: String) {
    let backendURL = "http://localhost:3000/api/auth/github/callback"
    
    var request = URLRequest(url: URL(string: backendURL)!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body = [
        "code": code,
        "redirect_uri": "affilia://auth/github/callback"
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        // Handle response
    }.resume()
}
```

### Step 7-8: Backend Exchanges Code for Token
```javascript
// Backend Server
app.post('/api/auth/github/callback', async (req, res) => {
    const { code } = req.body;
    
    // Exchange code for access token
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
    // accessToken = "ghu_1234567890abcdefghijklmnop..."
```

### Step 9-10: Backend Fetches User Profile
```javascript
    // Fetch user profile with access token
    const userResponse = await axios.get(
        'https://api.github.com/user',
        {
            headers: {
                Authorization: `Bearer ${accessToken}`,
                Accept: 'application/vnd.github.v3+json'
            }
        }
    );
    
    const user = userResponse.data;
    // {
    //   id: 12345,
    //   login: "robcodes",
    //   name: "Rob Behbahani",
    //   public_repos: 42,
    //   followers: 234,
    //   ...
    // }
```

### Step 11: Backend Returns Profile
```javascript
    // Return to iOS app
    res.json({
        token: "affilia_session_token_123",
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
});
```

### Step 12: iOS App Stores Profile
```swift
// iOS App
@MainActor
private func linkGitHubProfile(githubResponse: GitHubAuthResponse) {
    self.githubProfile = githubResponse.profile
    
    // Now you can use:
    // authManager.githubProfile?.username
    // authManager.githubProfile?.publicRepos
    // authManager.githubProfile?.avatarURL
}
```

## 🔐 Security: Why We Need a Backend

### ❌ Why NOT Exchange Code Directly from iOS?

GitHub OAuth requires the **Client Secret** to exchange the code for a token.

**BAD** (Never do this):
```swift
// ❌ NEVER PUT CLIENT SECRET IN iOS APP!
let clientSecret = "1234567890abcdef..."  // Anyone can decompile and steal this!

// Anyone who gets your client secret can:
// - Impersonate your app
// - Access all your users' GitHub data
// - Make requests as your application
// - Cannot be revoked without creating new OAuth app
```

### ✅ Why Backend is Secure

```
┌──────────────────────────────────────┐
│  iOS App (Public)                    │
│  ✓ Contains Client ID (public)       │
│  ✓ Can be decompiled                 │
│  ✗ No secret keys                    │
└──────────────────────────────────────┘
                  ↓
         Sends code only
                  ↓
┌──────────────────────────────────────┐
│  Backend Server (Private)            │
│  ✓ Contains Client Secret (private)  │
│  ✓ Cannot be accessed by users       │
│  ✓ Secrets in environment variables  │
│  ✓ Only you control it               │
└──────────────────────────────────────┘
```

## 📊 Data Flow Summary

| Step | Location | Data |
|------|----------|------|
| 1 | iOS | Client ID |
| 2 | GitHub | Authorization request |
| 3 | GitHub | User authorizes |
| 4 | iOS | Authorization code |
| 5 | Backend | Code sent to server |
| 6 | Backend → GitHub | Code + Client Secret |
| 7 | GitHub → Backend | Access token |
| 8 | Backend → GitHub | Request user data |
| 9 | GitHub → Backend | User profile |
| 10 | Backend → iOS | Profile (no token) |
| 11 | iOS | Store profile |

## 🎯 Key Points

1. **Client ID** = Public (safe in iOS app)
2. **Client Secret** = Private (ONLY on backend)
3. **Authorization Code** = One-time use (expires quickly)
4. **Access Token** = Stays on backend (never sent to iOS)
5. **User Profile** = Public data (safe to send to iOS)

## 🔄 What Each Component Knows

### iOS App Knows:
- ✓ Client ID (public)
- ✓ User's profile data
- ✓ Session token (from your backend)
- ✗ Client Secret
- ✗ GitHub access token

### Backend Server Knows:
- ✓ Client ID
- ✓ Client Secret
- ✓ GitHub access token
- ✓ User profile data
- ✓ Can make API calls to GitHub

### GitHub Knows:
- ✓ Your Client ID and Secret
- ✓ Which users authorized your app
- ✓ What scopes they granted
- ✗ Your session tokens
- ✗ What data you store

## 🚀 Testing the Flow

Run this in order:

1. **Start backend**: `cd backend && npm start`
2. **Run iOS app**: Xcode → Run
3. **Tap "Link GitHub"**
4. **Watch logs**:
   - iOS console: Code extracted
   - Backend terminal: Token exchange
   - iOS console: Profile received

You should see the full flow complete in ~2-3 seconds!
