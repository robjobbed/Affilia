# GitHub OAuth Setup Checklist

Use this checklist to ensure everything is configured correctly.

## 📋 Pre-Setup

- [ ] You have a GitHub account
- [ ] You have Node.js installed (`node --version`)
- [ ] You have npm installed (`npm --version`)
- [ ] Your iOS app project is open in Xcode

## 🔧 GitHub Configuration

- [ ] Go to https://github.com/settings/developers
- [ ] Click "OAuth Apps" → "New OAuth App"
- [ ] Fill in application details:
  - [ ] Application name: `Affilia` (or `Affilia Dev`)
  - [ ] Homepage URL: `http://localhost:3000` or `https://affilia.app`
  - [ ] Callback URL: `affilia://auth/github/callback`
- [ ] Click "Register application"
- [ ] Copy Client ID
- [ ] Generate and copy Client Secret
- [ ] Save both credentials securely

**Credentials Saved:**
```
Client ID: _______________________________________
Client Secret: ____________________________________
```

## 💻 Backend Setup

- [ ] Navigate to backend folder: `cd backend`
- [ ] Run `npm install`
- [ ] Open `github-oauth-server.js`
- [ ] Update `GITHUB_CLIENT_ID` with your Client ID
- [ ] Update `GITHUB_CLIENT_SECRET` with your Client Secret
- [ ] Save the file
- [ ] Run `npm start`
- [ ] Verify server shows: `✅ Server running on http://localhost:3000`
- [ ] Verify credentials show as: `✅ Set` (not `⚠️ NOT SET`)

**Backend Status:** ⬜ Running on port 3000

## 📱 iOS App Configuration

### Update AuthenticationManager.swift
- [ ] Open `AuthenticationManager.swift`
- [ ] Find `linkGitHub()` function (around line 305)
- [ ] Update `clientId` with your GitHub Client ID
- [ ] Save the file

```swift
let clientId = "YOUR_GITHUB_CLIENT_ID"  // ← Replace this
```

### Configure URL Scheme
- [ ] Select your **Affilia** target in Xcode
- [ ] Go to **Info** tab
- [ ] Scroll to **URL Types** section
- [ ] Verify or add URL Type:
  - [ ] Identifier: `com.affilia.auth`
  - [ ] URL Schemes: `affilia`
  - [ ] Role: `Editor`

**URL Scheme:** ⬜ Configured

### Verify Info.plist
- [ ] Right-click Info.plist → Open As → Source Code
- [ ] Verify contains URL scheme configuration:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.affilia.auth</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>affilia</string>
        </array>
    </dict>
</array>
```

## 🧪 Testing

### Pre-Test Checklist
- [ ] Backend server is running (`npm start` in backend folder)
- [ ] Backend shows credentials as `✅ Set`
- [ ] iOS app builds without errors (⌘B)
- [ ] You're logged into GitHub in Safari on your device/simulator

### Run Test
- [ ] Run iOS app (⌘R)
- [ ] Navigate to "Link GitHub" or profile settings
- [ ] Tap "Link GitHub" button
- [ ] Safari/web view opens
- [ ] GitHub authorization page appears
- [ ] Click "Authorize"
- [ ] App redirects back to Affilia
- [ ] No errors appear

### Verify in Xcode Console
Look for these log messages:

- [ ] `🔄 GitHub callback URL received: affilia://...`
- [ ] `✅ GitHub authorization code received: ...`
- [ ] `🌐 Sending GitHub authorization code to backend...`
- [ ] `📡 GitHub backend response status: 200`
- [ ] `✅ Successfully decoded GitHub profile from backend`
- [ ] `🔗 Linking GitHub profile to user...`
- [ ] `✅ GitHub linking complete!`

### Verify in Backend Terminal
Look for these log messages:

- [ ] `📥 Received GitHub OAuth callback`
- [ ] `🔄 Exchanging code for access token...`
- [ ] `✅ Got access token: ...`
- [ ] `👤 Fetching GitHub user profile...`
- [ ] `✅ Got GitHub user: your_username`
- [ ] `✅ Sending profile to iOS app`

### Verify in App
- [ ] GitHub profile data is available
- [ ] Can access `authManager.githubProfile`
- [ ] Username is displayed
- [ ] Repository count is shown
- [ ] Follower count is shown

## ✅ Success Criteria

All of these should be true:

- [ ] Backend server running without errors
- [ ] iOS app compiles and runs
- [ ] Tapping "Link GitHub" opens GitHub authorization
- [ ] Authorizing redirects back to app
- [ ] No error messages in Xcode console
- [ ] GitHub profile data is accessible in app
- [ ] No error messages in backend terminal

## 🐛 Troubleshooting

If something doesn't work, check:

### ❌ "Invalid redirect_uri"
- [ ] Callback URL in GitHub OAuth app is: `affilia://auth/github/callback`
- [ ] No typos in callback URL
- [ ] All lowercase

### ❌ No callback received
- [ ] URL scheme in Info.plist is `affilia` (lowercase)
- [ ] URL Type is properly configured
- [ ] App is set as default handler for `affilia://` URLs

### ❌ Backend 500 error
- [ ] Client Secret is correct (copy-paste again)
- [ ] Client ID is correct
- [ ] Backend terminal shows detailed error
- [ ] GitHub OAuth app exists and is active

### ❌ CORS error
- [ ] Backend includes CORS headers (already included in provided server)
- [ ] Backend URL is correct in iOS app
- [ ] Using `http://localhost:3000` for local development

### ❌ Can't reach backend
- [ ] Backend is running (`npm start`)
- [ ] Backend shows as listening on port 3000
- [ ] No firewall blocking port 3000
- [ ] Simulator/device can reach `http://localhost:3000`

### ❌ Simulator can't reach localhost
If testing on physical device:
- [ ] Backend is accessible on your network
- [ ] Use your computer's IP instead of localhost
- [ ] Example: `http://192.168.1.100:3000`

## 📝 Notes

**Date Configured:** __________________

**GitHub Client ID:** __________________

**Backend URL (Dev):** http://localhost:3000/api/auth/github/callback

**Backend URL (Prod):** _________________________________

**Issues Encountered:**
_________________________________________________
_________________________________________________
_________________________________________________

**Solutions Applied:**
_________________________________________________
_________________________________________________
_________________________________________________

## 🚀 Next Steps After Setup

- [ ] Add GitHub badge to profile
- [ ] Display repository list
- [ ] Show GitHub stats
- [ ] Use GitHub data for verification
- [ ] Import README as portfolio descriptions
- [ ] Show code contribution graph
- [ ] Display primary languages

## 🔐 Security Reminders

- [ ] Client Secret is NOT in git repository
- [ ] `.env` is in `.gitignore`
- [ ] Credentials are stored securely
- [ ] Using HTTPS in production
- [ ] State parameter validation enabled
- [ ] Backend validates all inputs

---

**Setup Complete:** ⬜ YES / ⬜ NO

**Tested Successfully:** ⬜ YES / ⬜ NO

**Production Ready:** ⬜ YES / ⬜ NO
