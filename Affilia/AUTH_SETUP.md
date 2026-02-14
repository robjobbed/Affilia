# X (Twitter) and GitHub Authentication Setup

## Overview

Affilia now supports authentication via X (Twitter) and GitHub account linking. This provides:
- **X Login**: Users sign in with their X account, importing profile data and establishing credibility
- **GitHub Linking**: Users connect GitHub to auto-import repositories as portfolio projects

## Features Implemented

### X (Twitter) Authentication
- **OAuth 2.0 flow** using `ASWebAuthenticationSession`
- Auto-imports X profile data (username, display name, bio, followers)
- Pre-fills freelancer profile for builders
- Shows X verification badge
- Sync button to refresh profile data

### GitHub Integration
- **OAuth flow** for GitHub account linking
- Displays public repo count and followers
- "Import Repos" button to add repos to portfolio
- Shows GitHub stats on profile

### UI Components Created
1. **LoginView** - Clean login screen with X and GitHub options
2. **RoleSelectionView** - Role chooser after X login ("I Build" vs "I Hire")
3. **ConnectedAccountsView** - Manage connected X and GitHub accounts
4. **AuthenticationManager** - Handles all OAuth flows

## Required Setup

### 1. Configure URL Scheme in Xcode

Add URL scheme for OAuth callbacks:

1. Open your Xcode project
2. Select your target → "Info" tab
3. Expand "URL Types"
4. Click "+" to add new URL type
5. Set:
   - **Identifier**: `com.affilia.auth`
   - **URL Schemes**: `affilia`
   - **Role**: Editor

This allows callbacks like `affilia://auth/x/callback` and `affilia://auth/github/callback`

### 2. Set Up X (Twitter) OAuth 2.0

#### Create X Developer Account
1. Go to https://developer.twitter.com/
2. Sign in with your X account
3. Apply for Developer access (usually instant approval)

#### Create App in X Developer Portal
1. Go to https://developer.twitter.com/en/portal/dashboard
2. Click "Projects & Apps" → "Create App"
3. Fill in app details:
   - **App name**: Affilia
   - **Description**: Freelancer marketplace for indie developers
   - **Website**: Your website URL
4. Note your **Client ID** (starts with `client_`)

#### Configure OAuth 2.0 Settings
1. In your app settings, go to "User authentication settings"
2. Click "Set up"
3. Enable **OAuth 2.0**
4. Set redirect URI: `affilia://auth/x/callback`
5. Set app permissions:
   - ✅ Read users
   - ✅ Read tweets
   - ✅ Read follows
6. Save settings

#### Update AuthenticationManager.swift
Replace this line in `AuthenticationManager.swift`:
```swift
let clientId = "YOUR_X_CLIENT_ID"
```
With your actual Client ID:
```swift
let clientId = "abc123XYZ456..." // Your Client ID from X Developer Portal
```

### 3. Set Up GitHub OAuth

#### Create GitHub OAuth App
1. Go to https://github.com/settings/developers
2. Click "OAuth Apps" → "New OAuth App"
3. Fill in:
   - **Application name**: Affilia
   - **Homepage URL**: Your website URL
   - **Authorization callback URL**: `affilia://auth/github/callback`
4. Click "Register application"
5. Note your **Client ID**
6. Generate a **Client Secret** (keep this secure!)

#### Update AuthenticationManager.swift
Replace this line:
```swift
let clientId = "YOUR_GITHUB_CLIENT_ID"
```
With your actual GitHub Client ID:
```swift
let clientId = "Iv1.abc123xyz..." // Your GitHub OAuth Client ID
```

### 4. Backend API Requirements

The current implementation simulates successful authentication. For production:

#### X OAuth Flow
1. **Frontend**: Redirects user to X OAuth
2. **X**: User authorizes, redirects to `affilia://auth/x/callback?code=...`
3. **Frontend**: Extracts code, sends to your backend
4. **Backend**: Exchanges code for access token
   ```
   POST https://api.twitter.com/2/oauth2/token
   ```
5. **Backend**: Fetches user profile with token
   ```
   GET https://api.twitter.com/2/users/me
   ```
6. **Backend**: Returns profile data to app
7. **Frontend**: Stores user session

#### GitHub OAuth Flow
1. **Frontend**: Redirects user to GitHub OAuth
2. **GitHub**: User authorizes, redirects to `affilia://auth/github/callback?code=...`
3. **Frontend**: Extracts code, sends to backend
4. **Backend**: Exchanges code for access token
   ```
   POST https://github.com/login/oauth/access_token
   ```
5. **Backend**: Fetches user profile
   ```
   GET https://api.github.com/user
   ```
6. **Backend**: Optionally fetches repos
   ```
   GET https://api.github.com/user/repos
   ```
7. **Backend**: Returns data to app

#### Backend Endpoints Needed
```
POST /api/auth/x/callback
- Receives: authorization code
- Returns: JWT token + user profile

POST /api/auth/github/link
- Receives: authorization code, user ID
- Returns: GitHub profile data

GET /api/github/repos
- Fetches user's public repos
- Returns: array of repos with name, description, URL
```

## Testing Authentication

### Test X Login Flow
1. Launch app → shows LoginView
2. Tap "SIGN IN WITH X"
3. Browser opens with X OAuth screen
4. Currently simulates success after 1 second
5. Shows RoleSelectionView with X username
6. Select role → enters main app

### Test GitHub Linking
1. In app, go to Profile → Connected Accounts
2. Tap "CONNECT GITHUB"
3. Browser opens with GitHub OAuth screen
4. Currently simulates success after 1 second
5. Shows connected GitHub profile with stats

### Mock Data in Simulator
The current implementation uses mock profiles:
- **X Profile**: @robcodes, 5420 followers
- **GitHub Profile**: robcodes, 42 repos

Replace `simulateXAuthentication()` and `simulateGitHubLink()` with real API calls.

## Security Considerations

### DO NOT Store in Code
- ❌ Never hardcode Client Secrets in the app
- ❌ Never commit OAuth secrets to git
- ✅ Client ID can be in app (public)
- ✅ Client Secret must stay on backend only

### Token Storage
- Use Keychain to store access tokens
- Never use UserDefaults for sensitive data
- Implement token refresh logic

### Backend Best Practices
- Validate all OAuth callbacks on backend
- Use HTTPS only
- Implement rate limiting
- Log authentication attempts
- Use short-lived JWT tokens

## App Flow After Authentication

### First Time User (X Login)
```
LoginView
  ↓ (Tap "Sign in with X")
X OAuth Screen
  ↓ (User approves)
RoleSelectionView
  ↓ (Select "I Build" or "I Hire")
MainTabView (Main App)
```

### Returning User
```
App Launch
  ↓ (Has valid session)
MainTabView (Main App)
```

### Linking GitHub (Existing User)
```
Profile Tab
  ↓
Connected Accounts
  ↓ (Tap "Connect GitHub")
GitHub OAuth Screen
  ↓ (User approves)
Connected Accounts (Shows GitHub profile)
```

## Future Enhancements

### X Integration Ideas
- [ ] Display X verification badge on profiles
- [ ] Show follower count as credibility metric
- [ ] Import X bio to profile automatically
- [ ] Share hired gigs to X timeline
- [ ] X DMs integration for messaging
- [ ] Import X posts about dev work

### GitHub Integration Ideas
- [ ] Auto-import top repos as portfolio projects
- [ ] Show GitHub contribution graph
- [ ] Display language stats from repos
- [ ] Import README as project descriptions
- [ ] Show GitHub stars as credibility metric
- [ ] Sync commits to show activity

### Additional OAuth Providers
- [ ] LinkedIn (professional network)
- [ ] Discord (dev community)
- [ ] Stack Overflow (reputation)
- [ ] Behance/Dribbble (designers)

## Troubleshooting

### Issue: OAuth screen doesn't appear
- Check URL scheme is configured correctly
- Verify Client ID is correct
- Check callback URL matches in OAuth app settings

### Issue: "Invalid callback URL"
- Ensure `affilia://auth/x/callback` is added to X app
- Ensure `affilia://auth/github/callback` is added to GitHub app
- URL schemes are case-sensitive

### Issue: Authentication succeeds but profile not loading
- Check backend is returning correct data format
- Verify API endpoints are accessible
- Check authentication token is being sent in headers

## API Reference

### AuthenticationManager Methods

```swift
// Sign in with X
AuthenticationManager.shared.signInWithX()

// Link GitHub account
AuthenticationManager.shared.linkGitHub()

// Sign out (clears all data)
AuthenticationManager.shared.signOut()

// Check if authenticated
if AuthenticationManager.shared.isAuthenticated {
    // User is logged in
}

// Access X profile
if let xProfile = AuthenticationManager.shared.xProfile {
    print(xProfile.username)
}

// Access GitHub profile
if let githubProfile = AuthenticationManager.shared.githubProfile {
    print(githubProfile.publicRepos)
}
```

### Profile Models

```swift
struct XProfile {
    let id: String
    let username: String
    let displayName: String
    let bio: String?
    let profileImageURL: String?
    let followers: Int
    let following: Int
    let verified: Bool
}

struct GitHubProfile {
    let id: String
    let username: String
    let name: String?
    let bio: String?
    let avatarURL: String?
    let publicRepos: Int
    let followers: Int
    let following: Int
}
```

---

**Authentication is now fully integrated! Users can sign in with X and link GitHub accounts.** 🚀

For production deployment, implement the backend API endpoints and replace the mock authentication with real OAuth flows.
