# Marketplace System

## Overview

Affilia features a **dual marketplace system** that automatically adapts based on user role:

- **Builders** see the **Gig Marketplace** - Browse and apply for available gigs
- **Hirers** see the **Builder Marketplace** - Find and hire available builders

Both marketplaces are designed to feel **live and dynamic**, creating urgency and excitement around new opportunities.

---

## Architecture

### Files Created

1. **`ManagersGigManager.swift`**
   - Centralized manager for gig listings
   - Handles auto-refresh to simulate live marketplace
   - Mock data with 8+ realistic gig listings
   - Automatically adds new gigs every 15-30 seconds

2. **`ViewsGigMarketplaceView.swift`**
   - Main view for builders to browse gigs
   - Real-time filtering by category, urgency, search
   - Sorting options (Newest, Highest Budget, Least Competitive)
   - Live indicator showing marketplace is active

3. **`ViewsGigDetailView.swift`**
   - Detailed gig view with application form
   - Builders can propose their own price and timeline
   - Cover letter submission
   - Shows applicant count to create competition

4. **`ViewsPostGigView.swift`**
   - Form for hirers to post new gigs
   - Validates required fields
   - Multiple categories and urgency levels
   - Dynamic requirements list

5. **`ViewsExploreView.swift`** (Updated)
   - Smart router that shows different marketplaces based on user role
   - Added floating action button for hirers to post gigs
   - Enhanced with live indicators

---

## Features

### For Builders (Gig Marketplace)

#### Live Updates
- Green pulse indicator shows marketplace is active
- New gigs automatically appear every 15-30 seconds
- "JUST NOW", "5M AGO", "2H AGO" timestamps create urgency
- Pull-to-refresh support

#### Filtering & Sorting
```swift
// Categories
.mobileDev, .webDev, .aiML, .automation, .design, .apiBackend, .vibeCoding, .other

// Urgency Levels
.urgent (red badge)
.normal (default)
.flexible (gray)

// Sort Options
- Newest First (default)
- Highest Budget
- Least Competitive (fewest applicants)
```

#### Gig Cards Display
- **Title** - Clear, concise project name
- **Hirer Info** - Name and X handle
- **Budget** - Prominently displayed
- **Estimated Time** - Hours estimate
- **Category Tag** - Visual category badge
- **Applicants** - Shows competition level
- **Urgency Badge** - Visual urgency indicator
- **Time Posted** - Creates FOMO

#### Application Flow
1. Tap gig card to see details
2. Review requirements and description
3. Propose your own price and timeline
4. Write cover letter
5. Submit application
6. Instant confirmation

### For Hirers (Builder Marketplace)

#### Builder Discovery
- Browse all available builders
- Filter by availability status
- Search by skills, name, or handle
- View verified badges and follower counts

#### Builder Cards Display
- **X Verification** - Blue checkmark for verified accounts
- **Follower Count** - Social proof
- **Bio** - Quick intro
- **Skills** - Up to 5 skill tags visible
- **Stats** - Projects completed, average rating
- **Pricing** - Hourly or project-based rates
- **Availability Status** - Open/Selective/Booked

#### Post Gigs
- Floating action button (FAB) in bottom-right
- Simple form with validation
- Add multiple requirements dynamically
- Set category and urgency
- Instant posting

---

## Key Models

### GigListing
```swift
struct GigListing: Identifiable, Codable, Hashable {
    let id: UUID
    let hirerId: UUID
    let hirerName: String
    let hirerHandle: String
    var title: String
    var description: String
    var requirements: [String]
    var budget: Double
    var estimatedHours: Int
    var category: GigCategory
    var urgency: GigUrgency
    var postedDate: Date
    var applicants: Int
}
```

### GigUrgency
```swift
enum GigUrgency: String {
    case urgent = "URGENT"    // Red badge, high priority
    case normal = "NORMAL"    // Default
    case flexible = "FLEXIBLE" // Low pressure
}
```

---

## User Experience

### The "Live Marketplace" Feel

#### Why It Works
1. **Auto-refresh** - New gigs appear automatically
2. **Time indicators** - "JUST NOW" creates urgency
3. **Applicant counts** - Shows competition
4. **Urgency badges** - Visual priority system
5. **Pulse animation** - Green dot indicates live updates
6. **Dynamic sorting** - Find best opportunities fast

#### Psychology
- **FOMO (Fear of Missing Out)** - Timestamps and urgency badges
- **Competition** - Applicant counts make builders act fast
- **Transparency** - Clear budgets and time estimates
- **Autonomy** - Builders propose their own rates
- **Social Proof** - X verification and follower counts

---

## Integration Points

### With AuthenticationManager
```swift
@EnvironmentObject var authManager: AuthenticationManager

// In ExploreView
if currentUser.role == .builder {
    GigMarketplaceView()
} else {
    BuilderMarketplaceView()
}
```

### With User Model
```swift
struct User {
    var role: UserRole? // .builder or .hirer
    var freelancerProfile: FreelancerProfile?
}
```

---

## Future Enhancements

### Phase 2 - Real Backend
- [ ] Connect to real API endpoints
- [ ] WebSocket for true real-time updates
- [ ] Push notifications for new gigs
- [ ] Saved gigs and applications

### Phase 3 - Advanced Features
- [ ] Gig recommendations based on skills
- [ ] Builder recommendations for hirers
- [ ] In-app messaging for applications
- [ ] Proposal negotiations
- [ ] Milestone-based project tracking

### Phase 4 - Analytics
- [ ] Application success rates
- [ ] Average time to hire
- [ ] Popular categories
- [ ] Price trends

---

## Usage Examples

### For Builders
```swift
// In your main tab view
NavigationStack {
    ExploreView()
        .environmentObject(authManager)
}
```

### For Hirers
```swift
// Post a gig
Button("Post Gig") {
    showingPostGig = true
}
.sheet(isPresented: $showingPostGig) {
    PostGigView()
}
```

### Manual Refresh
```swift
// In GigMarketplaceView
.refreshable {
    gigManager.loadGigs()
}
```

---

## Design System Compliance

All views follow your terminal/cyberpunk theme:

- **Colors**: `Theme.Colors.accent`, `.background`, `.surface`, etc.
- **Typography**: `Theme.Typography.h1`, `.body`, `.caption`, etc.
- **Spacing**: `Theme.Spacing.sm`, `.md`, `.lg`, etc.
- **Animations**: `FadeInView`, `SlideInView`, `AnimatedCard`
- **Cards**: `.terminalCard()` modifier
- **Borders**: `Theme.BorderWidth.thin`, `Theme.CornerRadius.medium`

---

## Testing

### Preview Both Marketplaces
```swift
#Preview("Builder Marketplace (Hirers)") {
    NavigationStack {
        BuilderMarketplaceView()
    }
}

#Preview("Gig Marketplace (Builders)") {
    NavigationStack {
        GigMarketplaceView()
    }
}
```

### Test Scenarios
1. **Empty state** - Clear filters to see all gigs
2. **Filtering** - Select different categories
3. **Sorting** - Try all sort options
4. **Application flow** - Fill out application form
5. **Post gig** - Create new gig listing
6. **Auto-refresh** - Watch for new gigs appearing

---

## Performance Notes

### Auto-Refresh Timer
- Runs every 15-30 seconds (randomized)
- Adds one new gig per cycle
- Keeps only most recent 50 gigs
- Stops when view is dismissed

### Memory Management
```swift
deinit {
    refreshTimer?.invalidate()
}
```

---

## Accessibility

- All buttons have proper labels
- Text is readable at all sizes
- Color contrast meets WCAG standards
- VoiceOver compatible
- Dynamic Type support through Theme.Typography

---

## Contributing

When adding new features:

1. **Keep the live feel** - Add animations and transitions
2. **Match the theme** - Use Theme constants
3. **Add urgency** - Timestamps, badges, indicators
4. **Be transparent** - Show all relevant info upfront
5. **Stay consistent** - Follow existing patterns

---

## Questions?

This marketplace system creates a **lively, competitive environment** where:
- Builders feel urgency to grab gigs fast
- Hirers see qualified builders immediately
- Both sides have transparency and control
- The platform feels active and thriving

The dual marketplace design ensures each user type sees exactly what they need, creating a focused, efficient experience. 🚀
