# Affilia - Affiliate Network for Brands and Partners

A native SwiftUI app pivoted into an affiliate network where:
- Affiliates create profiles and join campaign contracts.
- Companies publish affiliate contracts with commission terms.
- Both sides manage performance and payouts in one marketplace.

## Recent Updates (Feb 3, 2026)

### ✅ X (Twitter) & GitHub Authentication
- **Sign in with X** - OAuth 2.0 login flow
- **Link GitHub** - Connect GitHub account for portfolio integration
- Auto-import profile data from X
- Display social proof (followers, repos, verification)
- Role selection after X login (Affiliate vs Company)
- Connected Accounts management screen
- Mock authentication for testing (backend integration needed)

### ✅ Removed All Emojis
- Replaced emoji avatars with clean, terminal-style initials in bordered boxes
- Removed `avatarEmoji` property from `FreelancerProfile` model
- Created new `AvatarView` component with monospace initials
- Updated all views to use the new avatar system
- Maintains pure hacker terminal aesthetic

### ✅ Apple Pay Integration
- Full Apple Pay payment flow for payouts and contract-related payments
- `PaymentManager` class handles all payment logic
- `HireFreelancerView` provides complete payment UI
- Features:
  - Quick select amounts based on hourly/project rates
  - Custom amount input
  - Project description requirement
  - 5% platform fee automatically calculated
  - Payment breakdown with transparency
  - Success screen with confirmation
  - Error handling for common issues

## Design Philosophy

Affilia uses a **hacker terminal / retro command-line aesthetic** with:

- Pure black backgrounds (#000000)
- Neon green accents (#00FF41) for CTAs and highlights
- Amber/orange (#FFB800) for secondary actions
- Monospace fonts (Menlo) throughout the entire app
- Sharp, boxy UI elements with minimal corner radius
- Terminal-style loading indicators and empty states
- Dark mode only (no light mode option)
- NO emojis - clean initials-based avatars only

Design inspiration: https://parasite.space/

## Project Structure

```
Solomine/
├── Theme.swift                          # Centralized theme system
├── MockData.swift                       # Sample data (no emojis)
├── PaymentManager.swift                 # Apple Pay integration
├── AuthenticationManager.swift          # X & GitHub OAuth (NEW)
├── APPLE_PAY_SETUP.md                   # Payment setup guide
├── AUTH_SETUP.md                        # Authentication setup guide (NEW)
├── Models/
│   ├── FreelancerProfile.swift         # Profile model (no emoji field)
│   ├── Gig.swift                       # Service listing model
│   ├── Message.swift                   # Messaging models
│   └── UserRole.swift                  # User and role models
├── Components/
│   ├── AvatarView.swift                # Initial-based avatars
│   ├── TerminalButton.swift            # Terminal-styled buttons
│   ├── SkillTag.swift                  # Skill and category tags
│   ├── TerminalHeader.swift            # Section headers
│   └── LoadingIndicator.swift          # Loading animations
└── Views/
    ├── LoginView.swift                 # X/GitHub login screen (NEW)
    ├── RoleSelectionView.swift         # Role chooser after login (NEW)
    ├── ConnectedAccountsView.swift     # Manage social accounts (NEW)
    ├── MainTabView.swift               # Main tab navigation
    ├── ExploreView.swift               # Browse freelancers
    ├── FreelancerDetailView.swift      # Detailed profile + Hire button
    ├── HireFreelancerView.swift        # Apple Pay payment flow
    ├── GigsView.swift                  # Service listings
    ├── MessagesView.swift              # Messaging interface
    ├── DashboardView.swift             # User dashboard
    └── ProfileView.swift               # User profile & settings
```

## Features Implemented

### ✅ Core Features
- **X (Twitter) Authentication**: OAuth 2.0 sign-in with X (NEW)
- **GitHub Account Linking**: Connect GitHub for portfolio integration (NEW)
- **Dual Role System**: Users can be "I Build" (freelancer) or "I Hire" (client)
- **Browse & Discovery**: Search and filter freelancers by skills, availability, and ratings
- **Freelancer Profiles**: Complete profiles with bio, skills, portfolio, pricing, and stats
- **Service Listings (Gigs)**: Structured service offerings with deliverables and pricing
- **Messaging**: Basic conversation list view
- **Dashboard**: Role-specific dashboards for freelancers and clients
- **Profile Management**: User profiles with stats and settings
- **Apple Pay Integration**: Secure payment processing for hiring freelancers
- **Clean Avatars**: Initial-based avatars maintaining terminal aesthetic
- **Connected Accounts**: Manage X and GitHub integrations (NEW)

### 🎨 Design System
- Centralized `Theme.swift` with all colors, fonts, spacing constants
- Reusable terminal-styled components
- Custom terminal tab bar with monospace fonts
- Terminal-style search bars, buttons, and cards
- Blinking cursor animations and loading indicators
- Initial-based avatars in bordered boxes
- NO emoji anywhere in the app

### 📱 Navigation
Bottom tab bar with 5 sections:
1. **Explore** - Browse available freelancers
2. **Gigs** - View service listings
3. **Messages** - Conversations
4. **Dashboard** - Activity overview
5. **Profile** - User settings

## Apple Pay Setup

See `APPLE_PAY_SETUP.md` for complete setup instructions.

**Quick setup:**
1. Add Apple Pay capability in Xcode
2. Create Merchant ID in Apple Developer account
3. Update `PaymentManager.swift` with your Merchant ID
4. Add test card to Wallet in simulator/device
5. Backend integration needed for production

**Current status:** Frontend complete, simulates successful payments. Backend integration required for production.

## Mock Data

The app includes realistic placeholder data:
- 6 sample freelancer profiles with diverse skills (no emojis)
- 7 sample gigs across different categories
- 3 sample conversations with messages
- Sample user with client role

## Technical Details

- **Framework**: SwiftUI (iOS 17+)
- **Architecture**: MVVM pattern
- **Payments**: PassKit (Apple Pay)
- **No Backend**: Uses mock/sample data only (payment backend needed)
- **Color Scheme**: Dark mode enforced
- **Fonts**: Menlo monospace throughout
- **No Emojis**: Clean initials-based avatars

## How to Run

1. Open the project in Xcode
2. Select an iOS simulator (iOS 17+)
3. Build and run (⌘R)

The app will launch with the LoginView for authentication.

**Authentication Flow:**
1. Launch app → LoginView appears
2. Tap "SIGN IN WITH X" → simulated X OAuth (1 sec)
3. RoleSelectionView appears → choose "I Build" or "I Hire"
4. Enter main app with full access

**To test X/GitHub integration:**
- Follow setup in `AUTH_SETUP.md`
- Configure OAuth apps on X and GitHub
- Update client IDs in `AuthenticationManager.swift`

**To test payments:**
1. Follow setup in `APPLE_PAY_SETUP.md`
2. Add Apple Pay test card
3. Navigate to any freelancer profile
4. Tap "HIRE NOW"
5. Complete payment flow

## Web MVP

A lightweight browser prototype is included at:
- `/Users/rob/Desktop/Affilia/Solomine/web/index.html`

Open the file directly in a browser to test:
- Affiliate contract browsing and apply flow
- Company contract publishing flow

## Design Guidelines

### Colors
- Background: `#000000` or `#0A0A0A`
- Surface: `#1A1A1A`
- Border: `#333333`
- Primary Text: `#E0E0E0`
- Accent (Green): `#00FF41`
- Secondary Accent (Amber): `#FFB800`

### Typography
All text uses **Menlo** monospace font at various sizes:
- Body: 14pt
- Caption: 12pt
- Tiny: 10pt
- Title: 16pt
- Heading: 18pt
- Heading Large: 24pt

### UI Elements
- Corner radius: Max 4px
- Borders: 1px solid
- Buttons: Outlined style with invert on active
- Cards: Dark grey with subtle borders
- Headers: ALL CAPS with letter spacing
- Avatars: Initials in bordered boxes (NO emojis)

## Next Steps

### Required for Production
- [ ] Backend API for payment processing
- [ ] Real authentication system
- [ ] Database for users, gigs, messages
- [ ] Push notifications
- [ ] File upload for portfolio images
- [ ] Escrow system for payments
- [ ] Review/rating system after project completion

### Nice to Have
- [ ] Onboarding flow
- [ ] Advanced search/filters
- [ ] In-app messaging with real-time
- [ ] Video call integration
- [ ] Contract templates
- [ ] Time tracking
- [ ] Invoice generation

## Notes

This is an MVP focused on design and core user flow. The Apple Pay integration is frontend-complete but requires backend implementation for production use. All emoji references have been removed and replaced with a clean, terminal-aesthetic avatar system.

---

**Built with SwiftUI for iOS**
**Zero emojis. Pure terminal aesthetic. Secure payments ready.**
