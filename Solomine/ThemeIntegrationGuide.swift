//
//  ThemeIntegrationGuide.swift
//  Solomine
//
//  Integration guide for light/dark mode theme switching
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

/*

# Light/Dark Mode Integration Guide

## Overview

Your app now supports three theme modes:
- 🌙 **Dark Mode** (your current hacker terminal aesthetic)
- ☀️ **Light Mode** (clean, bright interface)
- 🔄 **System** (follows device settings)

## Quick Start

### Step 1: Apply Theme to Your App

In your main app file (e.g., `SolomineApp.swift`):

```swift
@main
struct SolomineApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .applyTheme() // ← Add this!
        }
    }
}
```

Or apply it to your root view:

```swift
struct ContentView: View {
    var body: some View {
        NavigationStack {
            // Your content
        }
        .applyTheme() // ← Add this!
    }
}
```

### Step 2: Add Settings Button

Add a settings button to your navigation bar:

```swift
struct MainView: View {
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            // Your content
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(Theme.Colors.accent)
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}
```

### Step 3: Setup Color Assets (Required!)

**Important**: You need to create the color assets in Xcode:

1. Open `Assets.xcassets`
2. Create each color set as described in `COLOR_ASSETS_SETUP.md`
3. Configure light/dark variants for each color

**OR** use the temporary fallback approach (see below).

---

## Temporary Fallback (No Asset Catalog)

If you don't want to setup color assets yet, you can use a temporary environment-based approach:

```swift
struct TemporaryThemeColors {
    @Environment(\.colorScheme) var colorScheme
    
    var background: Color {
        colorScheme == .dark ? 
            Theme.DarkColors.background : 
            Theme.LightColors.background
    }
    
    var textPrimary: Color {
        colorScheme == .dark ?
            Theme.DarkColors.textPrimary :
            Theme.LightColors.textPrimary
    }
    
    // ... etc for other colors
}
```

But the **proper way** is to use Asset Catalog colors!

---

## Usage Examples

### Example 1: Simple View with Theme

```swift
struct MyView: View {
    var body: some View {
        VStack {
            Text("Hello, Solomine!")
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text("This adapts to light/dark mode")
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding()
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.medium)
    }
}
```

### Example 2: Settings Menu Integration

Add a theme picker anywhere in your app:

```swift
struct QuickThemePicker: View {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Menu {
            ForEach(AppTheme.allCases, id: \.self) { theme in
                Button {
                    themeManager.setTheme(theme)
                } label: {
                    HStack {
                        Text(theme.rawValue)
                        if themeManager.currentTheme == theme {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: themeManager.currentTheme.icon)
                .foregroundColor(Theme.Colors.accent)
        }
    }
}
```

### Example 3: Theme Toggle Button

Quick toggle between light and dark:

```swift
struct ThemeToggleButton: View {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Button {
            // Toggle between light and dark
            let newTheme: AppTheme = themeManager.currentTheme == .dark ? .light : .dark
            themeManager.setTheme(newTheme)
        } label: {
            Image(systemName: themeManager.currentTheme == .dark ? "sun.max.fill" : "moon.fill")
                .font(.title2)
                .foregroundColor(Theme.Colors.accent)
        }
    }
}
```

### Example 4: Add to TabView

```swift
TabView {
    ExploreView()
        .tabItem { Label("Explore", systemImage: "magnifyingglass") }
    
    GigsView()
        .tabItem { Label("Gigs", systemImage: "briefcase") }
    
    // NEW: Settings tab
    SettingsView()
        .tabItem { Label("Settings", systemImage: "gearshape") }
}
.applyTheme()
```

---

## Architecture Overview

### Files Created

1. **`ThemeManager.swift`**
   - `ThemeManager` - Singleton that manages theme state
   - `AppTheme` enum - System/Light/Dark options
   - Persists preference to UserDefaults

2. **`Theme.swift`** (Updated)
   - `Theme.Colors` - Now use adaptive Color assets
   - `Theme.DarkColors` - Legacy/fallback dark colors
   - `Theme.LightColors` - New light mode colors
   - `Theme.Typography` - Extended font styles

3. **`ThemeModifier.swift`**
   - `ThemeModifier` - View modifier to apply theme
   - `.applyTheme()` - Extension method

4. **`ViewsSettingsView.swift`**
   - Complete settings UI
   - Theme picker with icons
   - Account info section
   - About section

5. **`COLOR_ASSETS_SETUP.md`**
   - Step-by-step guide to setup color assets
   - Hex values for all colors
   - JSON configuration examples

---

## Theme Persistence

The theme preference is automatically saved to `UserDefaults`:

```swift
// Saved when changed
themeManager.setTheme(.dark)

// Loaded on app launch
ThemeManager.shared // reads saved preference
```

---

## Testing

### Test Light Mode
1. Run app
2. Go to Settings
3. Select "Light" theme
4. All screens should switch to light mode

### Test Dark Mode
1. Go to Settings
2. Select "Dark" theme
3. All screens should switch to dark mode (your current style)

### Test System Mode
1. Go to Settings
2. Select "System" theme
3. Change device appearance in iOS Settings
4. App should follow device settings

---

## Migration from Old Colors

Your existing code using `Theme.Colors.*` will automatically work if you:

1. **Option A**: Setup color assets (recommended)
   - Colors adapt automatically to light/dark mode

2. **Option B**: Keep using hardcoded colors temporarily
   - Use `Theme.DarkColors.*` or `Theme.LightColors.*` explicitly
   - Not recommended long-term

---

## Customizing Light Mode Colors

Don't like the default light mode colors? Change them!

In `Theme.swift`:

```swift
struct LightColors {
    static let background = Color(hex: "F8F8F8") // Change this
    static let textPrimary = Color(hex: "1A1A1A") // Change this
    // ... etc
}
```

Then update the corresponding Asset Catalog colors.

---

## Advanced: Custom Theme

Want to add more themes? (e.g., "Midnight Blue", "Sunset")

1. Extend `AppTheme` enum:
```swift
enum AppTheme: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    case midnight = "Midnight Blue" // NEW
}
```

2. Create color variants in asset catalog
3. Handle in ThemeManager if needed

---

## Troubleshooting

### Colors not changing?
- Make sure you created color assets in `Assets.xcassets`
- Verify color names match exactly (case-sensitive)
- Check you added `.applyTheme()` to your root view

### Settings button not showing?
- Add it to your navigation toolbar
- Or add Settings tab to TabView

### Theme not persisting?
- Check UserDefaults access
- Verify ThemeManager is a singleton (`static let shared`)

---

## What's Next?

### Immediate
1. ✅ Add `.applyTheme()` to your root view
2. ✅ Add settings button/tab
3. ✅ Create color assets in Xcode
4. ✅ Test theme switching

### Optional Enhancements
- Add haptic feedback when switching themes
- Add theme preview before applying
- Add more theme variants
- Animate theme transitions
- Add theme scheduling (auto dark at night)

---

## Example: Complete Integration

Here's a complete example showing how to integrate everything:

*/

// MARK: - Complete Example App Structure

// Example code - DO NOT use @main here as it conflicts with the real SolomineApp.swift
// @main
struct ExampleSolomineApp: App {
    var body: some Scene {
        WindowGroup {
            ExampleRootView()
                .applyTheme() // Apply theme to entire app
        }
    }
}

struct ExampleRootView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                ExampleMainAppView()
            } else {
                // LoginView() // Reference to actual view
                Text("Login View")
            }
        }
    }
}

struct ExampleMainAppView: View {
    @State private var showingSettings = false
    
    var body: some View {
        TabView {
            NavigationStack {
                ExampleExploreView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                showingSettings = true
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(Theme.Colors.accent)
                            }
                        }
                    }
            }
            .tabItem {
                Label("Explore", systemImage: "magnifyingglass")
            }
            
            NavigationStack {
                ExampleAgentMarketplaceView()
            }
            .tabItem {
                Label("Agents", systemImage: "sparkles")
            }
            
            NavigationStack {
                ExampleSettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .sheet(isPresented: $showingSettings) {
            ExampleSettingsView()
        }
    }
}

// Example placeholder views
struct ExampleExploreView: View {
    var body: some View {
        Text("Explore View")
    }
}

struct ExampleAgentMarketplaceView: View {
    var body: some View {
        Text("Agent Marketplace")
    }
}

struct ExampleSettingsView: View {
    var body: some View {
        Text("Settings")
    }
}

struct ExampleView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Text("Welcome to Solomine")
                .font(Theme.Typography.h1)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text("This view adapts to light and dark mode automatically!")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Button("Primary Action") {
                // Action
            }
            .font(Theme.Typography.body.weight(.bold))
            .foregroundColor(Theme.Colors.background)
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.accent)
            .cornerRadius(Theme.CornerRadius.medium)
        }
        .padding(Theme.Spacing.xl)
        .background(Theme.Colors.background)
    }
}

/*

## Summary

You now have:
- ✅ Light/Dark/System theme support
- ✅ Settings UI for theme switching
- ✅ Persistent theme preference
- ✅ Smooth theme transitions
- ✅ Adaptive color system
- ✅ Complete integration guide

Your hacker terminal aesthetic in dark mode is preserved, and users can now choose light mode if they prefer!

*/
