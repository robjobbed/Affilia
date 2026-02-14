# Quick Setup Reference Card

## 1. Xcode URL Scheme (Required)
```
Target → Info → URL Types → Add New
Identifier: com.solomine.auth
URL Schemes: solomine
```

## 2. X (Twitter) OAuth Setup

### Get Client ID
1. https://developer.twitter.com/en/portal/dashboard
2. Create App → Note Client ID
3. User Authentication Settings → OAuth 2.0
4. Redirect URI: `solomine://auth/x/callback`
5. Permissions: Read users, tweets, follows

### Update Code
```swift
// AuthenticationManager.swift line ~32
let clientId = "YOUR_X_CLIENT_ID_HERE"
```

## 3. GitHub OAuth Setup

### Get Client ID
1. https://github.com/settings/developers
2. New OAuth App
3. Callback: `solomine://auth/github/callback`
4. Note Client ID

### Update Code
```swift
// AuthenticationManager.swift line ~90
let clientId = "YOUR_GITHUB_CLIENT_ID_HERE"
```

## 4. Apple Pay Setup (Optional for Testing)

### Get Merchant ID
1. https://developer.apple.com/account/resources/identifiers/list/merchant
2. Create new Merchant ID
3. Format: `merchant.com.solomine.payments`

### Update Code
```swift
// PaymentManager.swift line ~52
request.merchantIdentifier = "YOUR_MERCHANT_ID"
```

### Add Capability
```
Target → Signing & Capabilities → + Capability
Add: Apple Pay
Add your Merchant ID to the list
```

## 5. Test Without Backend

All OAuth flows currently simulate success after 1 second. You can test:
- Login flow
- Role selection
- Profile connections
- Payment UI
- All navigation

The app is fully functional for UI/UX testing without any backend setup.

## 6. Backend Integration Needed For

- Real X OAuth token exchange
- Real GitHub OAuth token exchange
- X API calls (profile, tweets)
- GitHub API calls (repos, profile)
- Apple Pay payment processing
- User session management
- Database operations

---

## Quick Test Flow

```bash
# 1. Open in Xcode
open Solomine.xcodeproj

# 2. Run in simulator
⌘ + R

# 3. Test login (simulated)
Tap "SIGN IN WITH X" → Wait 1s → Select Role

# 4. Test GitHub linking
Profile → Connected Accounts → Connect GitHub → Wait 1s

# 5. Test payment
Explore → Pick freelancer → Hire Now → Enter details → Pay
```

---

**For full setup details, see AUTH_SETUP.md and APPLE_PAY_SETUP.md**
