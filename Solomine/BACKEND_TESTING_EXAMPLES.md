# Mock Backend Response Examples

## For Testing Your Backend Implementation

When building your backend endpoint, use these examples to ensure compatibility with the iOS app.

## Success Response (200 OK)

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxMjM0NTY3ODkiLCJ4VXNlcm5hbWUiOiJyb2Jjb2RlcyJ9.abc123",
  "profile": {
    "id": "123456789",
    "username": "robcodes",
    "displayName": "Rob Behbahani",
    "bio": "Full-stack indie dev. SwiftUI wizard. Building Solomine.",
    "profileImageURL": "https://pbs.twimg.com/profile_images/123/avatar.jpg",
    "followers": 5420,
    "following": 892,
    "verified": false,
    "email": "rob@x.com"
  }
}
```

## Other Real User Examples

### High Follower Count User
```json
{
  "token": "jwt_token_here",
  "profile": {
    "id": "987654321",
    "username": "sama",
    "displayName": "Sam Altman",
    "bio": "OpenAI CEO",
    "profileImageURL": "https://pbs.twimg.com/profile_images/...",
    "followers": 2850000,
    "following": 1420,
    "verified": true,
    "email": "sama@x.com"
  }
}
```

### Developer with GitHub Link
```json
{
  "token": "jwt_token_here",
  "profile": {
    "id": "555666777",
    "username": "swiftdevgirl",
    "displayName": "Sarah Chen",
    "bio": "iOS Engineer @ Tech Co | SwiftUI enthusiast | Open source contributor",
    "profileImageURL": "https://pbs.twimg.com/profile_images/...",
    "followers": 8420,
    "following": 342,
    "verified": false,
    "email": "sarah@x.com"
  }
}
```

## Error Responses

### Invalid Authorization Code (400)
```json
{
  "error": "invalid_grant",
  "message": "The authorization code is invalid or has expired"
}
```

### X API Rate Limit (429)
```json
{
  "error": "rate_limit_exceeded",
  "message": "Too many authentication attempts. Please try again later."
}
```

### X API Error (503)
```json
{
  "error": "service_unavailable",
  "message": "X API is currently unavailable. Please try again later."
}
```

### Backend Server Error (500)
```json
{
  "error": "internal_server_error",
  "message": "An unexpected error occurred during authentication"
}
```

## Testing with cURL

### Test Your Backend Endpoint
```bash
curl -X POST https://your-backend.com/api/auth/x/callback \
  -H "Content-Type: application/json" \
  -d '{
    "code": "TEST_AUTH_CODE_123",
    "redirect_uri": "solomine://auth/x/callback"
  }'
```

### Expected Response
```bash
HTTP/1.1 200 OK
Content-Type: application/json

{
  "token": "eyJhbGciOiJIUzI1NiIsInR...",
  "profile": {
    "id": "123456789",
    "username": "robcodes",
    ...
  }
}
```

## iOS App Decoding

The iOS app expects exactly this structure:
```swift
struct XAuthResponse: Codable {
    let token: String
    let profile: XProfile
}

struct XProfile: Codable {
    let id: String
    let username: String
    let displayName: String
    let bio: String?
    let profileImageURL: String?
    let followers: Int
    let following: Int
    let verified: Bool
    let email: String?
}
```

## Testing Checklist

When implementing your backend:

- [ ] Endpoint responds at `POST /api/auth/x/callback`
- [ ] Accepts JSON body with `code` and `redirect_uri`
- [ ] Returns 200 status on success
- [ ] Returns JSON with `token` and `profile` fields
- [ ] Profile includes all required fields
- [ ] Profile image URL is valid (or null)
- [ ] Email is included (or null if unavailable)
- [ ] Errors return appropriate status codes (400, 500, etc.)
- [ ] CORS is configured if needed
- [ ] HTTPS is enabled
- [ ] Rate limiting is implemented

## Mock Backend for Testing

If you want to test the iOS app before implementing the real backend:

### Simple Mock Server (Node.js)
```javascript
const express = require('express');
const app = express();

app.use(express.json());

app.post('/api/auth/x/callback', (req, res) => {
  // Simulate delay
  setTimeout(() => {
    res.json({
      token: 'mock_jwt_token_' + Date.now(),
      profile: {
        id: '123456789',
        username: 'testuser',
        displayName: 'Test User',
        bio: 'iOS developer testing Solomine',
        profileImageURL: null,
        followers: 100,
        following: 50,
        verified: false,
        email: 'test@x.com'
      }
    });
  }, 500);
});

app.listen(3000, () => {
  console.log('Mock backend running on http://localhost:3000');
});
```

### Run Mock Server
```bash
node mock-server.js
```

### Update iOS App
```swift
// In AuthenticationManager.swift
let backendURL = "http://localhost:3000/api/auth/x/callback"
```

## Production Checklist

Before deploying:

- [ ] Backend URL uses HTTPS
- [ ] Client Secret is in environment variables (not code)
- [ ] X access tokens are encrypted in database
- [ ] JWT tokens have reasonable expiration (7-30 days)
- [ ] Refresh token logic is implemented
- [ ] Error handling is comprehensive
- [ ] Logging is set up for debugging
- [ ] Rate limiting prevents abuse
- [ ] CORS is configured correctly
- [ ] Input validation on all fields
- [ ] SQL injection prevention (if using SQL)
- [ ] XSS prevention on stored data

---

Use these examples to validate your backend implementation! 🚀
