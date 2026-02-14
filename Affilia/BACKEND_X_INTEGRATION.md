# Backend X (Twitter) Integration Guide

## Overview

This guide explains how to set up your backend to exchange X OAuth authorization codes for access tokens and fetch real user profile data.

## Updated Authentication Flow

### 1. iOS App Flow
```
User taps "Sign in with X"
  ↓
ASWebAuthenticationSession opens X OAuth
  ↓
User authorizes app on X
  ↓
X redirects to: affilia://auth/x/callback?code=ABC123...
  ↓
App extracts authorization code
  ↓
App sends code to YOUR backend: POST /api/auth/x/callback
  ↓
Backend exchanges code for access token with X API
  ↓
Backend fetches user profile from X API
  ↓
Backend returns profile data + session token to app
  ↓
App stores user with REAL X username, bio, followers, etc.
```

## Backend Implementation

### Endpoint: POST /api/auth/x/callback

**Purpose**: Exchange authorization code for access token and fetch user profile

**Request Body**:
```json
{
  "code": "AUTHORIZATION_CODE_FROM_X",
  "redirect_uri": "affilia://auth/x/callback"
}
```

**Backend Process**:

#### Step 1: Exchange Code for Access Token
```bash
POST https://api.twitter.com/2/oauth2/token
Content-Type: application/x-www-form-urlencoded

code=AUTHORIZATION_CODE
grant_type=authorization_code
client_id=YOUR_X_CLIENT_ID
redirect_uri=affilia://auth/x/callback
code_verifier=challenge
```

**X API Response**:
```json
{
  "token_type": "bearer",
  "expires_in": 7200,
  "access_token": "ACCESS_TOKEN_HERE",
  "scope": "tweet.read users.read follows.read",
  "refresh_token": "REFRESH_TOKEN_HERE"
}
```

#### Step 2: Fetch User Profile with Access Token
```bash
GET https://api.twitter.com/2/users/me?user.fields=id,name,username,description,profile_image_url,public_metrics,verified
Authorization: Bearer ACCESS_TOKEN_HERE
```

**X API Response**:
```json
{
  "data": {
    "id": "123456789",
    "name": "Rob Behbahani",
    "username": "robcodes",
    "description": "Full-stack indie dev. SwiftUI wizard. Building Affilia.",
    "profile_image_url": "https://pbs.twimg.com/profile_images/...",
    "public_metrics": {
      "followers_count": 5420,
      "following_count": 892,
      "tweet_count": 1234,
      "listed_count": 42
    },
    "verified": false
  }
}
```

#### Step 3: Create/Update User in Your Database
```javascript
// Pseudo-code for backend
const xProfile = {
  id: userData.id,
  username: userData.username,
  displayName: userData.name,
  bio: userData.description,
  profileImageURL: userData.profile_image_url,
  followers: userData.public_metrics.followers_count,
  following: userData.public_metrics.following_count,
  verified: userData.verified
};

// Find or create user in your database
let user = await db.users.findOne({ xUserId: xProfile.id });

if (!user) {
  // New user - create record
  user = await db.users.create({
    xUserId: xProfile.id,
    xUsername: xProfile.username,
    email: `${xProfile.username}@x.com`, // Or fetch from X if available
    displayName: xProfile.displayName,
    bio: xProfile.bio,
    profileImageURL: xProfile.profileImageURL,
    xFollowers: xProfile.followers,
    xFollowing: xProfile.following,
    xVerified: xProfile.verified,
    createdAt: new Date(),
    role: null // User will select role in app
  });
} else {
  // Existing user - update profile
  await db.users.update(user.id, {
    displayName: xProfile.displayName,
    bio: xProfile.bio,
    profileImageURL: xProfile.profileImageURL,
    xFollowers: xProfile.followers,
    xFollowing: xProfile.following,
    xVerified: xProfile.verified,
    lastLogin: new Date()
  });
}
```

#### Step 4: Generate Session Token for Your App
```javascript
// Create JWT or session token
const sessionToken = jwt.sign(
  { 
    userId: user.id,
    xUsername: user.xUsername
  },
  process.env.JWT_SECRET,
  { expiresIn: '30d' }
);

// Store refresh token securely (encrypted in DB)
await db.tokens.create({
  userId: user.id,
  xAccessToken: encrypt(accessToken),
  xRefreshToken: encrypt(refreshToken),
  expiresAt: new Date(Date.now() + 7200 * 1000)
});
```

#### Step 5: Return to iOS App
```json
{
  "token": "YOUR_JWT_SESSION_TOKEN",
  "profile": {
    "id": "123456789",
    "username": "robcodes",
    "displayName": "Rob Behbahani",
    "bio": "Full-stack indie dev. SwiftUI wizard. Building Affilia.",
    "profileImageURL": "https://pbs.twimg.com/profile_images/...",
    "followers": 5420,
    "following": 892,
    "verified": false,
    "email": "robcodes@x.com"
  }
}
```

## Example Backend Implementation (Node.js/Express)

```javascript
const express = require('express');
const axios = require('axios');
const jwt = require('jsonwebtoken');

const router = express.Router();

router.post('/api/auth/x/callback', async (req, res) => {
  try {
    const { code, redirect_uri } = req.body;
    
    // Step 1: Exchange code for access token
    const tokenResponse = await axios.post(
      'https://api.twitter.com/2/oauth2/token',
      new URLSearchParams({
        code: code,
        grant_type: 'authorization_code',
        client_id: process.env.X_CLIENT_ID,
        redirect_uri: redirect_uri,
        code_verifier: 'challenge' // Use PKCE in production
      }),
      {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': `Basic ${Buffer.from(`${process.env.X_CLIENT_ID}:${process.env.X_CLIENT_SECRET}`).toString('base64')}`
        }
      }
    );
    
    const accessToken = tokenResponse.data.access_token;
    const refreshToken = tokenResponse.data.refresh_token;
    
    // Step 2: Fetch user profile
    const profileResponse = await axios.get(
      'https://api.twitter.com/2/users/me',
      {
        headers: {
          'Authorization': `Bearer ${accessToken}`
        },
        params: {
          'user.fields': 'id,name,username,description,profile_image_url,public_metrics,verified'
        }
      }
    );
    
    const userData = profileResponse.data.data;
    
    // Step 3: Create/update user in database
    const xProfile = {
      id: userData.id,
      username: userData.username,
      displayName: userData.name,
      bio: userData.description,
      profileImageURL: userData.profile_image_url,
      followers: userData.public_metrics.followers_count,
      following: userData.public_metrics.following_count,
      verified: userData.verified,
      email: `${userData.username}@x.com` // Or fetch real email if scope allows
    };
    
    let user = await db.users.findOne({ xUserId: xProfile.id });
    
    if (!user) {
      user = await db.users.create({
        xUserId: xProfile.id,
        xUsername: xProfile.username,
        email: xProfile.email,
        displayName: xProfile.displayName,
        bio: xProfile.bio,
        profileImageURL: xProfile.profileImageURL,
        xFollowers: xProfile.followers,
        xFollowing: xProfile.following,
        xVerified: xProfile.verified,
        role: null,
        createdAt: new Date()
      });
    } else {
      await db.users.update(user.id, {
        displayName: xProfile.displayName,
        bio: xProfile.bio,
        profileImageURL: xProfile.profileImageURL,
        xFollowers: xProfile.followers,
        xFollowing: xProfile.following,
        lastLogin: new Date()
      });
    }
    
    // Step 4: Generate session token
    const sessionToken = jwt.sign(
      { userId: user.id, xUsername: user.xUsername },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );
    
    // Store X tokens securely
    await db.tokens.create({
      userId: user.id,
      xAccessToken: encrypt(accessToken),
      xRefreshToken: encrypt(refreshToken),
      expiresAt: new Date(Date.now() + 7200 * 1000)
    });
    
    // Step 5: Return to iOS app
    res.json({
      token: sessionToken,
      profile: xProfile
    });
    
  } catch (error) {
    console.error('X OAuth error:', error.response?.data || error.message);
    res.status(500).json({
      error: 'Authentication failed',
      message: error.response?.data?.error_description || error.message
    });
  }
});

module.exports = router;
```

## iOS App Configuration

Update the backend URL in `AuthenticationManager.swift`:

```swift
// Replace this line in exchangeXCodeForProfile()
let backendURL = "https://your-backend.com/api/auth/x/callback"

// With your actual backend URL:
let backendURL = "https://api.affilia.app/api/auth/x/callback"
```

## Testing the Integration

### 1. Development Environment
For local testing:
```swift
let backendURL = "http://localhost:3000/api/auth/x/callback"
```

### 2. Test Authentication Flow
1. Run your backend locally
2. Launch iOS app in simulator
3. Tap "Sign in with X"
4. Authorize the app
5. Check backend logs for API calls
6. Verify profile data is returned to app

### 3. Check Logs
Backend should log:
```
✅ Received authorization code
✅ Exchanged code for access token
✅ Fetched X profile: @robcodes
✅ Created/updated user in database
✅ Returning profile to iOS app
```

iOS app should log:
```
✅ Authorization code received
🌐 Sending authorization code to backend...
📡 Backend response status: 200
✅ Successfully decoded X profile from backend
👤 X Profile: @robcodes (5420 followers)
✅ Authentication complete!
```

## Production Deployment

### Security Checklist
- [ ] Use HTTPS for all API calls
- [ ] Store X Client Secret securely (environment variables)
- [ ] Never expose Client Secret to iOS app
- [ ] Implement rate limiting on auth endpoint
- [ ] Use PKCE (Proof Key for Code Exchange) for additional security
- [ ] Encrypt stored access tokens in database
- [ ] Implement token refresh logic
- [ ] Set short JWT expiration times
- [ ] Validate all incoming requests
- [ ] Log authentication attempts for security monitoring

### Environment Variables
```bash
X_CLIENT_ID=your_client_id_here
X_CLIENT_SECRET=your_client_secret_here
JWT_SECRET=your_jwt_secret_here
DATABASE_URL=your_database_url_here
```

### Database Schema
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  x_user_id VARCHAR(255) UNIQUE,
  x_username VARCHAR(255) UNIQUE,
  email VARCHAR(255),
  display_name VARCHAR(255),
  bio TEXT,
  profile_image_url TEXT,
  x_followers INT,
  x_following INT,
  x_verified BOOLEAN,
  role VARCHAR(50),
  created_at TIMESTAMP,
  last_login TIMESTAMP
);

CREATE TABLE tokens (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  x_access_token TEXT, -- encrypted
  x_refresh_token TEXT, -- encrypted
  expires_at TIMESTAMP,
  created_at TIMESTAMP
);
```

## Fallback Behavior

The iOS app automatically falls back to mock data if:
- Backend URL is not configured
- Backend returns an error
- Network request fails

This allows development to continue without a backend. The mock profile shows:
```
Username: @robcodes
Display Name: Rob Behbahani
Followers: 5420
```

## Refreshing Profile Data

To allow users to sync their latest X profile:

### Backend Endpoint: GET /api/auth/x/refresh
```javascript
router.get('/api/auth/x/refresh', authenticateUser, async (req, res) => {
  // Get stored access token
  const token = await db.tokens.findOne({ userId: req.userId });
  
  // Fetch latest profile from X
  const profile = await fetchXProfile(token.xAccessToken);
  
  // Update user in database
  await db.users.update(req.userId, {
    displayName: profile.displayName,
    bio: profile.bio,
    xFollowers: profile.followers,
    xFollowing: profile.following
  });
  
  res.json({ profile });
});
```

### iOS Implementation:
```swift
func refreshXProfile() async throws {
    // Call backend to refresh profile
    // Update local xProfile
}
```

## Next Steps

1. **Set up backend server** (Node.js, Python, Go, etc.)
2. **Implement `/api/auth/x/callback` endpoint**
3. **Configure X OAuth credentials** in environment variables
4. **Test authentication flow** end-to-end
5. **Deploy backend** to production
6. **Update iOS app** with production backend URL
7. **Test with real X accounts**

---

**Now your app will use REAL X usernames and profile data! 🚀**

Users who sign in with X will see their actual username, bio, follower count, and profile picture throughout the app.
