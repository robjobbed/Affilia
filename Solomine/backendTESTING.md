# Testing the Complete Backend

## Quick Test (2 minutes)

### 1. Start Backend
```bash
cd backend
npm run dev
```

You should see:
```
🚀 Solomine Backend Server
📡 Server running on port 3000
🌍 Environment: development
✅ Database connected
```

### 2. Test Health Endpoint
```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2026-02-03T...",
  "environment": "development"
}
```

### 3. Test with iOS App
1. Make sure backend is running
2. Open Xcode and run the app
3. Tap "Sign in with X"
4. Authorize the app
5. Watch backend logs

Expected backend logs:
```
📥 Received X OAuth callback
   Code: ABC123...
🔄 Exchanging code for access token...
✅ Access token received
👤 Fetching X user profile...
✅ Profile fetched: @yourusername
🆕 Creating new user
✅ User created: [uuid]
🔐 OAuth tokens stored
🎫 JWT token generated
✅ Authentication complete for @yourusername
```

Expected iOS logs:
```
✅ Authorization code received: ABC123...
🌐 Sending authorization code to backend...
📡 Backend response status: 200
✅ Successfully decoded X profile from backend
🔐 Creating user from X profile...
   - Username: @yourusername
   - Display Name: Your Name
   - Followers: 1234
✅ Authentication complete! User should now select their role.
```

## Full Integration Test

### Test 1: New User Sign In

**Steps:**
1. Sign in with X for the first time
2. Check that user is created in database
3. Verify profile data matches X profile

**Verify in Database:**
```bash
npm run studio
# Opens Prisma Studio at http://localhost:5555
# Navigate to User table
# Should see your X username, followers, etc.
```

### Test 2: Returning User Sign In

**Steps:**
1. Sign in with X (same account as before)
2. Check that existing user is updated (not duplicated)
3. Verify `lastLogin` timestamp is updated

**Verify:**
- Only ONE user record in database
- `xFollowers` updated if changed
- `lastLogin` is recent

### Test 3: Set User Role

After signing in, the app should show RoleSelectionView.

**API Call:**
```bash
# Get JWT token from backend logs (or iOS app logs)
TOKEN="your_jwt_token_here"

# Set role to builder
curl -X PUT http://localhost:3000/api/users/me/role \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role": "I BUILD"}'
```

**Expected Response:**
```json
{
  "user": {
    "id": "uuid-here",
    "role": "I BUILD"
  }
}
```

### Test 4: Update Profile

**API Call:**
```bash
curl -X PUT http://localhost:3000/api/users/me \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bio": "Full-stack iOS developer",
    "skills": ["SwiftUI", "UIKit", "Node.js"],
    "hourlyRate": 150,
    "availability": "OPEN_TO_WORK"
  }'
```

**Expected Response:**
```json
{
  "user": {
    "id": "...",
    "email": "...",
    "role": "I BUILD",
    "xUsername": "yourusername",
    "bio": "Full-stack iOS developer",
    "skills": ["SwiftUI", "UIKit", "Node.js"],
    "hourlyRate": 150,
    "availability": "OPEN_TO_WORK",
    ...
  }
}
```

### Test 5: Get Current User

**API Call:**
```bash
curl http://localhost:3000/api/users/me \
  -H "Authorization: Bearer $TOKEN"
```

**Expected Response:**
```json
{
  "user": {
    "id": "uuid",
    "email": "yourusername@x.com",
    "role": "I BUILD",
    "xUsername": "yourusername",
    "displayName": "Your Name",
    "bio": "...",
    "profileImageUrl": "https://pbs.twimg.com/...",
    "xFollowers": 1234,
    "xFollowing": 567,
    "xVerified": false,
    "skills": ["SwiftUI", "UIKit", "Node.js"],
    "hourlyRate": 150,
    "availability": "OPEN_TO_WORK",
    "portfolioProjects": null,
    "projectsCompleted": 0,
    "averageRating": null,
    "memberSince": "2026-02-03T..."
  }
}
```

### Test 6: Get User by Username

**API Call:**
```bash
curl http://localhost:3000/api/users/yourusername \
  -H "Authorization: Bearer $TOKEN"
```

**Expected Response:**
Same as Test 5, but public profile (no email)

### Test 7: Refresh X Profile

**API Call:**
```bash
curl -X POST http://localhost:3000/api/auth/x/refresh \
  -H "Authorization: Bearer $TOKEN"
```

**Expected Response:**
```json
{
  "profile": {
    "id": "123456789",
    "username": "yourusername",
    "displayName": "Your Name",
    "bio": "...",
    "profileImageURL": "...",
    "followers": 1234,
    "following": 567,
    "verified": false,
    "email": "yourusername@x.com"
  }
}
```

### Test 8: Logout

**API Call:**
```bash
curl -X POST http://localhost:3000/api/auth/logout \
  -H "Authorization: Bearer $TOKEN"
```

**Expected Response:**
```json
{
  "message": "Logged out successfully"
}
```

**Verify:** Token should be deleted from database

## Error Testing

### Test Invalid Token

**API Call:**
```bash
curl http://localhost:3000/api/users/me \
  -H "Authorization: Bearer invalid_token"
```

**Expected Response:**
```json
{
  "error": "Unauthorized",
  "message": "Invalid or expired token"
}
```

### Test Missing Token

**API Call:**
```bash
curl http://localhost:3000/api/users/me
```

**Expected Response:**
```json
{
  "error": "Unauthorized",
  "message": "No authentication token provided"
}
```

### Test Invalid Role

**API Call:**
```bash
curl -X PUT http://localhost:3000/api/users/me/role \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role": "INVALID"}'
```

**Expected Response:**
```json
{
  "error": "Bad Request",
  "message": "Role must be \"I BUILD\" or \"I HIRE\""
}
```

## Database Verification

### Check Users Table
```bash
npm run studio
```

Navigate to http://localhost:5555 and verify:
- ✅ User record exists
- ✅ X username is correct
- ✅ Followers count matches X profile
- ✅ Profile image URL is present
- ✅ Role is set correctly

### Check Tokens Table
Verify:
- ✅ Token record exists for user
- ✅ `xAccessToken` is encrypted (long hex string)
- ✅ `expiresAt` is in the future

## Performance Testing

### Test Rate Limiting
```bash
# Send 101 requests rapidly
for i in {1..101}; do
  curl http://localhost:3000/health
done
```

After 100 requests, you should get:
```json
{
  "message": "Too many requests from this IP, please try again later."
}
```

## Production Readiness Checklist

Test these before deploying:

- [ ] X OAuth works with real accounts
- [ ] Users are created correctly
- [ ] Profile data is accurate
- [ ] Tokens are encrypted in database
- [ ] JWT tokens work for authentication
- [ ] Rate limiting prevents abuse
- [ ] Error messages are appropriate
- [ ] No sensitive data in logs
- [ ] CORS allows iOS app requests
- [ ] Database migrations run successfully
- [ ] All environment variables are set
- [ ] HTTPS is enabled (production)

## Troubleshooting

### Backend Returns 500 Error
Check logs for detailed error message:
```bash
# Backend should log the error
# Look for red ❌ messages
```

### X OAuth Fails
Verify:
- X_CLIENT_ID is correct in .env
- X_CLIENT_SECRET is correct in .env
- X app has correct redirect URI
- X app has correct scopes enabled

### Database Connection Fails
```bash
# Check PostgreSQL is running
brew services list | grep postgresql

# Start if not running
brew services start postgresql@15
```

### iOS App Can't Reach Backend
- Make sure backend is running (`npm run dev`)
- Check backend URL in AuthenticationManager.swift
- For simulator, use `http://localhost:3000`
- For device, use your computer's IP address

---

## Success Criteria

✅ Backend starts without errors
✅ Database connection successful
✅ Health endpoint responds
✅ X OAuth exchange works
✅ User profile is fetched from X
✅ User is created/updated in database
✅ JWT token is generated
✅ iOS app receives profile data
✅ User can select role
✅ User can update profile
✅ All endpoints return correct responses

**If all tests pass, you're ready to ship! 🚀**
