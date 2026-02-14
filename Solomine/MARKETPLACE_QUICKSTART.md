# Quick Start: Marketplace Integration

## Overview
This guide shows how to integrate the new dual marketplace system into your existing Solomine app.

---

## Step 1: Update Your Main ContentView

Make sure `AuthenticationManager` is available as an environment object:

```swift
@main
struct SolomineApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
```

---

## Step 2: Update Your Tab View

Your existing explore tab should automatically work with the new dual marketplace:

```swift
struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        TabView {
            NavigationStack {
                ExploreView()
                    .environmentObject(authManager)
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Explore")
            }
            
            // ... other tabs
        }
    }
}
```

That's it! The `ExploreView` now automatically shows:
- **Gig Marketplace** for builders
- **Builder Marketplace** for hirers

---

## Step 3: (Optional) Add Direct Access

If you want dedicated navigation to each marketplace:

### For Builder Dashboard
```swift
NavigationLink {
    GigMarketplaceView()
} label: {
    HStack {
        Image(systemName: "briefcase")
        Text("BROWSE GIGS")
    }
}
```

### For Hirer Dashboard
```swift
NavigationLink {
    BuilderMarketplaceView()
} label: {
    HStack {
        Image(systemName: "person.2")
        Text("FIND BUILDERS")
    }
}

Button {
    showingPostGig = true
} label: {
    HStack {
        Image(systemName: "plus.circle")
        Text("POST A GIG")
    }
}
.sheet(isPresented: $showingPostGig) {
    PostGigView()
}
```

---

## How It Works

### Role-Based Routing

The `ExploreView` automatically detects user role:

```swift
struct ExploreView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        Group {
            if let currentUser = authManager.currentUser {
                if currentUser.role == .builder {
                    // Show gigs to builders
                    GigMarketplaceView()
                } else {
                    // Show builders to hirers
                    BuilderMarketplaceView()
                }
            } else {
                // Not logged in - show builders by default
                BuilderMarketplaceView()
            }
        }
    }
}
```

### Data Management

The `GigManager` is a shared singleton that handles all gig data:

```swift
@StateObject private var gigManager = GigManager.shared

// Access anywhere in your app
GigManager.shared.availableGigs
GigManager.shared.loadGigs()
GigManager.shared.postGig(newGig)
```

---

## What Happens for Each User Type

### When a BUILDER opens Explore:
1. Sees `GigMarketplaceView`
2. Browses available gigs
3. Can filter by category/urgency
4. Can apply to gigs
5. New gigs appear automatically every 15-30 seconds

### When a HIRER opens Explore:
1. Sees `BuilderMarketplaceView`
2. Browses available builders
3. Can filter by availability/skills
4. Can view builder profiles
5. Has floating button to post new gigs

### When NOT logged in:
1. Sees `BuilderMarketplaceView` (default)
2. Encourages sign-up to access features

---

## Testing Different Roles

To test as a builder:
```swift
authManager.currentUser = User(
    id: UUID(),
    email: "builder@test.com",
    role: .builder,
    freelancerProfile: someProfile
)
```

To test as a hirer:
```swift
authManager.currentUser = User(
    id: UUID(),
    email: "hirer@test.com",
    role: .hirer
)
```

---

## Customization

### Adjust Auto-Refresh Timing
In `GigManager.swift`:
```swift
// Change the interval (default: 15-30 seconds)
refreshTimer = Timer.scheduledTimer(
    withTimeInterval: Double.random(in: 15...30), // Change these values
    repeats: true
) { ... }
```

### Customize Gig Urgency Colors
In `GigUrgency`:
```swift
var color: String {
    switch self {
    case .urgent: return "red"        // Change to any color
    case .normal: return "accent"
    case .flexible: return "textSecondary"
    }
}
```

### Add More Categories
In `ModelsGig.swift`:
```swift
enum GigCategory: String, CaseIterable, Codable {
    case mobileDev = "MOBILE DEV"
    case webDev = "WEB DEV"
    case aiML = "AI/ML"
    case yourNewCategory = "YOUR CATEGORY" // Add here
}
```

---

## Backend Integration (Future)

When you're ready to connect to a real backend:

### 1. Replace Mock Data
```swift
func loadGigs() async {
    isLoading = true
    
    do {
        let url = URL(string: "https://api.solomine.app/gigs")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let gigs = try JSONDecoder().decode([GigListing].self, from: data)
        
        await MainActor.run {
            self.availableGigs = gigs
            self.isLoading = false
        }
    } catch {
        print("Error loading gigs: \(error)")
        isLoading = false
    }
}
```

### 2. WebSocket for Real-Time Updates
```swift
import Starscream

class GigManager: ObservableObject, WebSocketDelegate {
    private var socket: WebSocket?
    
    func connectToRealTime() {
        var request = URLRequest(url: URL(string: "wss://api.solomine.app/gigs/live")!)
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .text(let text):
            if let data = text.data(using: .utf8),
               let newGig = try? JSONDecoder().decode(GigListing.self, from: data) {
                availableGigs.insert(newGig, at: 0)
            }
        default:
            break
        }
    }
}
```

---

## Troubleshooting

### "User role is nil"
Make sure the user selects a role after authentication:
```swift
// In RoleSelectionView or onboarding
authManager.currentUser?.role = selectedRole
```

### "No gigs showing"
Check that `GigManager` is loaded:
```swift
.onAppear {
    if gigManager.availableGigs.isEmpty {
        gigManager.loadGigs()
    }
}
```

### "Auto-refresh not working"
Verify timer is running:
```swift
// In GigManager init
startAutoRefresh()
```

---

## Next Steps

1. ✅ Integrate into your main tab view
2. ✅ Test with different user roles
3. ✅ Customize categories and urgency levels
4. ⏭️ Connect to your backend API
5. ⏭️ Add push notifications for new gigs
6. ⏭️ Implement application tracking
7. ⏭️ Add messaging between builders and hirers

---

## Need Help?

The marketplace system is designed to be plug-and-play. Just add `ExploreView` to your navigation and it handles everything automatically based on user role!

Key files to know:
- `ViewsExploreView.swift` - Main entry point
- `ManagersGigManager.swift` - Data management
- `ViewsGigMarketplaceView.swift` - Builder view
- `ViewsGigDetailView.swift` - Gig details
- `ViewsPostGigView.swift` - Post new gigs

All views follow your existing theme and design patterns. 🎨
