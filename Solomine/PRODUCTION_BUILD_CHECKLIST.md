# Production Build Checklist Script

## Before Running Archive

### 1. Update Config.swift
```swift
// Config.swift - Line 15
static let isProduction = true  // ✅ Changed from false
```

### 2. Update API URLs
```swift
// Config.swift - Lines 22-23
static let apiBaseURL: String = {
    if isProduction {
        return "https://api.solomine.io"  // ✅ Your production URL
    } else {
        return "http://localhost:3000"
    }
}()
```

### 3. Enable Features (when ready)
```swift
// Config.swift - Feature Flags section
static let useRealBackend = true  // When backend is deployed
static let enablePayments = true  // When Stripe is configured
static let enablePushNotifications = true  // When APNS is configured
```

### 4. Update Info.plist Values
```xml
<!-- Check these keys in Info.plist -->
<key>CFBundleVersion</key>
<string>1</string>  <!-- Increment for each upload -->

<key>CFBundleShortVersionString</key>
<string>1.0.0</string>  <!-- User-facing version -->

<key>CFBundleIdentifier</key>
<string>com.solomine.app</string>  <!-- Your bundle ID -->
```

### 5. Remove Debug Code

**Search for these patterns:**
```swift
// Remove or comment out all instances of:
print("  // Debug logging
#if DEBUG  // Wrap debug code properly
TODO:  // Address or remove
FIXME:  // Fix before shipping
```

**Quick Find & Replace in Xcode:**
- Press Cmd+Shift+F
- Search: `print\("(?!✅|❌|⚠️|🔐|👤)`
- Filter: Show only non-commented code
- Review each print statement

### 6. Verify Privacy Policy URL
```swift
// Config.swift - Line 64
static let privacyPolicyURL = "https://solomine.io/privacy"  // ✅ Must be live
```

**Test URL before submission:**
```bash
curl -I https://solomine.io/privacy
# Should return: HTTP/1.1 200 OK
```

### 7. Build Configuration in Xcode

**For Release Build:**
1. Select "Any iOS Device (arm64)" as target
2. Product → Scheme → Edit Scheme
3. Run → Build Configuration → Release
4. Archive → Build Configuration → Release

**Build Settings to Check:**
- Swift Optimization Level: `-O` (Optimize for Speed)
- Strip Debug Symbols: Yes
- Enable Bitcode: No (deprecated)
- Dead Code Stripping: Yes

### 8. Pre-Archive Checklist

```bash
# Clean build folder
Cmd + Shift + K

# Run tests (if you have them)
Cmd + U

# Analyze for issues
Cmd + Shift + B

# Archive
Product → Archive
```

### 9. Validation Before Upload

**In Xcode Organizer:**
1. Select your archive
2. Click "Validate App"
3. Fix all errors
4. Fix warnings (recommended)
5. Click "Distribute App"
6. Choose "App Store Connect"
7. Upload

### 10. TestFlight Setup (Parallel to App Store)

**Why TestFlight?**
- Get early user feedback
- Test on real devices
- Catch bugs before public release
- Build confidence

**Steps:**
1. Same build uploaded to App Store Connect
2. Go to TestFlight tab
3. Add internal testers (up to 100)
4. Add external testers (up to 10,000)
5. Share beta link

---

## Quick Production Checklist

Copy this checklist before each production build:

```
PRODUCTION BUILD CHECKLIST v1.0

PRE-BUILD
[ ] Config.isProduction = true
[ ] API URLs updated
[ ] Privacy policy URL live and tested
[ ] OAuth credentials verified
[ ] Remove debug print statements
[ ] Version/build numbers incremented
[ ] All TODOs addressed or documented

BUILD
[ ] Clean build folder
[ ] Build scheme set to Release
[ ] Archive successfully created
[ ] No compiler warnings (or all reviewed)

VALIDATE
[ ] Validation passes in Organizer
[ ] No distribution errors
[ ] Export compliance answered
[ ] Upload successful

POST-UPLOAD
[ ] Build appears in App Store Connect
[ ] TestFlight enabled for beta testing
[ ] All app metadata complete
[ ] Screenshots uploaded
[ ] Submit for review

NOTES:
- Build Number: _____
- Upload Date: _____
- Any Issues: _____
```

---

## Emergency Rollback Plan

**If you need to pull the app after launch:**

1. **In App Store Connect:**
   - Go to App Store tab
   - Click "Remove from Sale"
   - App will be hidden within 24 hours

2. **Submit Update:**
   - Fix critical issue
   - Increment build number
   - Submit as expedited review
   - Reference original build in notes

3. **Communicate:**
   - Email users if possible
   - Post on social media
   - Update support documentation

---

## Version Numbering Strategy

**Semantic Versioning:**
- **Major.Minor.Patch** (e.g., 1.0.0)
- **Major**: Breaking changes (1.0.0 → 2.0.0)
- **Minor**: New features (1.0.0 → 1.1.0)
- **Patch**: Bug fixes (1.0.0 → 1.0.1)

**Build Numbers:**
- Increment for every upload
- Can be date-based: 20260204 (Feb 4, 2026)
- Or sequential: 1, 2, 3, etc.

**Example Timeline:**
```
v1.0.0 (Build 1) - Initial launch
v1.0.1 (Build 2) - Critical bug fix
v1.1.0 (Build 3) - Add push notifications
v1.1.1 (Build 4) - Fix notification crash
v2.0.0 (Build 5) - Major redesign
```

---

## Common Build Errors & Solutions

### Error: "No signing identity found"
**Solution:** 
1. Xcode → Settings → Accounts
2. Select your team
3. Download Manual Profiles
4. Or enable Automatic Signing

### Error: "Missing required icon"
**Solution:**
1. Add 1024x1024 app icon
2. Assets.xcassets → AppIcon
3. Fill all required sizes

### Error: "Invalid privacy policy URL"
**Solution:**
1. URL must be publicly accessible
2. Must be HTTPS (not HTTP)
3. Must return 200 OK status
4. Cannot redirect to login

### Error: "App uses encryption"
**Solution:**
1. Export Compliance Information
2. For HTTPS only: Select "No" for export
3. For additional encryption: Complete questionnaire

---

## Final Production Checklist - PASTE INTO NOTES

```
🚀 SOLOMINE PRODUCTION BUILD

Date: _______________
Version: 1.0.0
Build: _______________

✅ Config.isProduction = true
✅ API URLs updated to production
✅ Privacy Policy URL live: https://solomine.io/privacy
✅ Terms of Service URL live: https://solomine.io/terms
✅ Debug prints removed/disabled
✅ OAuth credentials verified (X & GitHub)
✅ Bundle identifier correct: com.solomine.app
✅ Version/Build numbers incremented
✅ Clean build successful
✅ Validation passes
✅ Upload to App Store Connect successful
✅ TestFlight enabled
✅ Screenshots uploaded (5+)
✅ App description complete
✅ Keywords added
✅ Support email verified: rob@solomine.io
✅ Submitted for review

NOTES:
_________________________________
_________________________________
_________________________________

READY FOR LAUNCH! 🎉
```

---

**Save this file and use it before every production build!**
