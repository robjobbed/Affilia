# ✅ SOLOMINE APP STORE SUBMISSION CHECKLIST

**Date:** _______________  
**Version:** 1.0.0  
**Build:** _______________  

---

## 🔥 CRITICAL (Must Do First)

- [ ] **Host Privacy Policy Online** (30 min)
  - [ ] Create GitHub repo or use Netlify/Vercel
  - [ ] Upload privacy.html (template in PRIVACY_POLICY_HOSTING.md)
  - [ ] Upload terms.html
  - [ ] Test URL works: ___________________________
  - [ ] Update Config.swift with URL
  - [ ] Verify URL returns 200 OK in browser

- [ ] **Test App on Real Device** (15 min)
  - [ ] Connect iPhone via USB
  - [ ] Run app (Cmd+R)
  - [ ] App launches without crash
  - [ ] Sign in flow works
  - [ ] Role selection works
  - [ ] Browse view loads
  - [ ] Settings opens
  - [ ] Terms/Privacy accessible
  - [ ] Contact Support opens email

---

## 📱 APP STORE ASSETS

### Screenshots (Required)
- [ ] **iPhone 15 Pro Max** (1290 x 2796)
  - [ ] Screenshot 1: Login screen
  - [ ] Screenshot 2: Role selection
  - [ ] Screenshot 3: Browse view
  - [ ] Screenshot 4: Profile view
  - [ ] Screenshot 5: Messages/Settings

- [ ] **iPhone 14 Plus** (1284 x 2778)
  - [ ] Screenshot 1
  - [ ] Screenshot 2
  - [ ] Screenshot 3

- [ ] **iPhone 8 Plus** (1242 x 2208)
  - [ ] Screenshot 1
  - [ ] Screenshot 2
  - [ ] Screenshot 3

### App Icon
- [ ] Export 1024x1024 PNG
- [ ] No alpha channel
- [ ] No rounded corners
- [ ] Looks good on white background

---

## 💻 CODE PREPARATION

### Config.swift Updates
- [ ] Privacy policy URL: ________________________________
- [ ] Terms of service URL: ________________________________
- [ ] Support email verified: rob@solomine.io
- [ ] isProduction = false (OK for v1.0 with mock data)

### Version Numbers
- [ ] CFBundleShortVersionString: 1.0.0
- [ ] CFBundleVersion: 1 (or higher)
- [ ] Bundle Identifier: ________________________________

### Code Quality
- [ ] App runs without crashes
- [ ] No placeholder text ("Lorem ipsum")
- [ ] All screens accessible
- [ ] Navigation works
- [ ] Theme switching works
- [ ] Legal docs open from Settings

---

## 🏗️ BUILD & ARCHIVE

- [ ] Clean Build Folder (Cmd+Shift+K)
- [ ] Select "Any iOS Device (arm64)"
- [ ] Product → Archive
- [ ] Archive completes successfully
- [ ] Open Organizer
- [ ] Select archive
- [ ] Click "Validate App"
- [ ] Validation passes
- [ ] Fix any errors/warnings
- [ ] Click "Distribute App"
- [ ] Choose "App Store Connect"
- [ ] Upload build
- [ ] Build appears in App Store Connect (wait ~5-10 min)

**Build Upload Time:** _______________

---

## 🌐 APP STORE CONNECT

### Create App
- [ ] Go to appstoreconnect.apple.com
- [ ] My Apps → + → New App
- [ ] Platform: iOS
- [ ] Name: Solomine
- [ ] Language: English (U.S.)
- [ ] Bundle ID: ________________________________
- [ ] SKU: solomine-ios

### App Information
- [ ] Name: Solomine
- [ ] Subtitle: Connect with Indie Developers (or your subtitle)
- [ ] Privacy Policy URL: ________________________________
- [ ] Support URL (optional): ________________________________
- [ ] Marketing URL (optional): ________________________________

### Pricing & Availability
- [ ] Price: Free
- [ ] Availability: All territories (or select specific)

### App Privacy
- [ ] Data Types:
  - [ ] Contact Info (Email)
  - [ ] Identifiers (User ID)
  - [ ] User Content (Messages, Profile)
  - [ ] Usage Data (Analytics)
- [ ] Data Use:
  - [ ] App functionality
  - [ ] Analytics (if enabled)

### Version Information
- [ ] Select uploaded build
- [ ] Screenshots uploaded for all sizes
- [ ] Description pasted (see template below)
- [ ] Keywords: freelance,developer,designer,hire,ios,swift,github,jobs,remote,indie
- [ ] What's New: Initial release of Solomine
- [ ] Promotional Text (optional): Where Builders Meet Opportunity

### Age Rating
- [ ] Complete questionnaire
- [ ] Likely rating: 4+ or 12+
- [ ] No gambling, violence, etc.

### App Review Information
- [ ] First Name: Rob
- [ ] Last Name: Behbahani  
- [ ] Phone: ________________________________
- [ ] Email: rob@solomine.io
- [ ] Demo Account (if needed): ________________________________
- [ ] Notes: See template below

### Export Compliance
- [ ] App uses encryption? YES (HTTPS)
- [ ] Encryption exempt? YES (standard HTTPS only)
- [ ] OR complete export compliance questionnaire

---

## 📝 TEMPLATES

### App Description (Max 4000 chars)
```
Solomine - Where Builders Meet Opportunity

Connect with talented independent developers and designers for your next project. 
Whether you're hiring or looking for work, Solomine makes it simple.

FOR BUILDERS
• Showcase your skills and experience
• Connect with X (Twitter) to highlight your social presence
• Get discovered by clients looking for your expertise
• Chat directly with potential clients

FOR CLIENTS
• Browse verified developers and designers
• Filter by skills and experience
• Review portfolios and social proof
• Message builders directly

FEATURES
✓ Secure X (Twitter) authentication
✓ GitHub integration for developers
✓ Real-time messaging
✓ Beautiful, dark mode interface
✓ Theme customization (Matte Black, Midnight Blue, Forest Green)
✓ Privacy-focused design

Perfect for indie developers, designers, startups, and anyone looking to hire 
top talent or find great projects.

Download Solomine today and start building connections.
```

### App Review Notes
```
Thank you for reviewing Solomine!

TESTING THE APP:
1. Launch app and tap "Sign in with X"
2. Tap "Cancel" to use mock authentication
3. Select "I'm a Builder" or "I'm Hiring"
4. Browse developer profiles
5. Navigate through app screens
6. Test Settings → Theme switching
7. Check Terms, Privacy, and Contact Support

FEATURES IN v1.0:
✓ Role selection (Builder/Client)
✓ Browse developers and projects
✓ Profile viewing with skills
✓ Messaging interface
✓ Theme customization
✓ Legal documents

MOCK DATA:
This is v1.0 using simulated authentication and sample data for initial launch.
Real backend integration and payments coming in v1.1.

CONTACT:
rob@solomine.io

Thank you!
```

---

## ✅ PRE-SUBMISSION FINAL CHECK

- [ ] Privacy policy URL works in browser
- [ ] All screenshots look professional
- [ ] App icon uploaded
- [ ] Description proofread
- [ ] Keywords added
- [ ] Build selected
- [ ] Age rating completed
- [ ] Contact info correct
- [ ] Review notes added

---

## 🚀 SUBMIT FOR REVIEW

- [ ] Click "Add for Review"
- [ ] Review all information one more time
- [ ] Click "Submit to App Review"
- [ ] See confirmation: "Waiting for Review"
- [ ] Note submission time: _______________

---

## 🎉 POST-SUBMISSION

### Immediate
- [ ] Screenshot confirmation page
- [ ] Save submission details
- [ ] Set up app monitoring (Xcode Organizer)
- [ ] Monitor rob@solomine.io for reviewer questions

### While Waiting (24-48 hours)
- [ ] Prepare social media posts
- [ ] Write launch announcement
- [ ] Create Product Hunt listing
- [ ] Set up TestFlight for beta testers
- [ ] Plan v1.1 features

### After Approval
- [ ] Release app immediately or schedule
- [ ] Post on X (Twitter)
- [ ] Submit to Product Hunt
- [ ] Post on Hacker News
- [ ] Email friends and early supporters
- [ ] Monitor crash reports
- [ ] Respond to user feedback

---

## 📊 TRACKING

### Submission Timeline
- Privacy hosted: _______________
- Screenshots taken: _______________
- Build archived: _______________
- Build uploaded: _______________
- App Store listing complete: _______________
- Submitted for review: _______________
- **Status:** Waiting for Review ✅

### Review Timeline (Apple provides)
- In Review: _______________
- Approved: _______________
- Released: _______________

---

## 🆘 IF REJECTED

1. Read rejection reason carefully
2. Fix the issue
3. Increment build number
4. Re-archive and upload
5. Re-submit (usually faster review)
6. Request expedited review if urgent

### Common Rejections
- **Missing privacy URL** → Host on GitHub Pages
- **Crash on launch** → Fix and test on device
- **Incomplete features** → Explain in review notes
- **Misleading screenshots** → Use real app screenshots

---

## ✅ FINAL GO/NO-GO

### ✅ GO IF:
- [x] Privacy policy URL is live
- [ ] App runs without crashes
- [ ] Screenshots look good
- [ ] All metadata complete
- [ ] Build uploaded successfully

### 🛑 NO-GO IF:
- [ ] No privacy policy URL
- [ ] App crashes on launch
- [ ] Can't upload build
- [ ] Major features broken

---

## 🎯 SUCCESS!

When you see **"Waiting for Review"** in App Store Connect, you're done!

**Estimated review time:** 24-48 hours

**What to do now:**
1. Relax! You did it! 🎉
2. Monitor your email
3. Prepare launch materials
4. Plan v1.1 features
5. Get ready to ship!

---

**Submitted by:** _______________  
**Date:** _______________  
**Time:** _______________  

🚀 **SOLOMINE IS ON ITS WAY TO THE APP STORE!** 🚀

---

*Print this checklist and check off items as you go!*
