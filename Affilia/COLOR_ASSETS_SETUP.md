# Color Assets Setup Guide

## Creating Adaptive Colors in Xcode

To make your colors automatically adapt to light and dark mode, you need to add them to your **Asset Catalog**.

### Step 1: Open Asset Catalog

1. In Xcode, open your project
2. Find `Assets.xcassets` in the Project Navigator
3. Click on it to open

### Step 2: Create Color Sets

For each color, right-click in the Assets catalog and select **"New Color Set"**. 

Create these color sets with the following configurations:

---

## Background Colors

### Background
- **Name**: `Background`
- **Any Appearance (Light)**: `#FFFFFF` (white)
- **Dark Appearance**: `#0D0D0D` (deep black)

### BackgroundElevated
- **Name**: `BackgroundElevated`
- **Any Appearance (Light)**: `#F8F8F8` (light grey)
- **Dark Appearance**: `#141414` (slightly elevated black)

### Surface
- **Name**: `Surface`
- **Any Appearance (Light)**: `#F5F5F5` (light grey)
- **Dark Appearance**: `#1A1A1A` (dark grey)

### Border
- **Name**: `Border`
- **Any Appearance (Light)**: `#E0E0E0` (light border)
- **Dark Appearance**: `#2A2A2A` (dark border)

---

## Text Colors

### TextPrimary
- **Name**: `TextPrimary`
- **Any Appearance (Light)**: `#1A1A1A` (almost black)
- **Dark Appearance**: `#E8E6E3` (warm off-white)

### TextSecondary
- **Name**: `TextSecondary`
- **Any Appearance (Light)**: `#666666` (medium grey)
- **Dark Appearance**: `#8A8A7A` (muted warm grey)

---

## Accent Colors

### Accent
- **Name**: `Accent`
- **Any Appearance (Light)**: `#9BAA7F` (olive green)
- **Dark Appearance**: `#9BAA7F` (same - consistent in both modes)

### TerminalGreen
- **Name**: `TerminalGreen`
- **Any Appearance (Light)**: `#7A8F6C` (sage green)
- **Dark Appearance**: `#7A8F6C` (same)

### AccentSecondary
- **Name**: `AccentSecondary`
- **Any Appearance (Light)**: `#C9A961` (warm amber)
- **Dark Appearance**: `#C9A961` (same)

---

## How to Add Each Color

### Visual Steps:

1. **Right-click** in Assets.xcassets
2. Select **"New Color Set"**
3. **Name** the color set (e.g., "Background")
4. In the **Attributes Inspector** (right panel):
   - Change "Appearances" to **"Any, Dark"**
5. Click on the **"Any Appearance"** color well
   - Enter the **Light Mode** hex color
6. Click on the **"Dark Appearance"** color well
   - Enter the **Dark Mode** hex color

### Example for "Background":

```
Color Set Name: Background

Appearances: Any, Dark

Any Appearance:
  Color: RGB Hex #FFFFFF
  
Dark Appearance:
  Color: RGB Hex #0D0D0D
```

---

## Quick Reference Table

| Color Name          | Light Mode Hex | Dark Mode Hex |
|---------------------|----------------|---------------|
| Background          | `#FFFFFF`      | `#0D0D0D`     |
| BackgroundElevated  | `#F8F8F8`      | `#141414`     |
| Surface             | `#F5F5F5`      | `#1A1A1A`     |
| Border              | `#E0E0E0`      | `#2A2A2A`     |
| TextPrimary         | `#1A1A1A`      | `#E8E6E3`     |
| TextSecondary       | `#666666`      | `#8A8A7A`     |
| Accent              | `#9BAA7F`      | `#9BAA7F`     |
| TerminalGreen       | `#7A8F6C`      | `#7A8F6C`     |
| AccentSecondary     | `#C9A961`      | `#C9A961`     |

---

## Alternative: JSON Configuration

If you prefer to configure via JSON, here's the structure for `Background.colorset`:

**Background.colorset/Contents.json**:
```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "1.000",
          "green" : "1.000",
          "red" : "1.000"
        }
      },
      "idiom" : "universal"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0.051",
          "green" : "0.051",
          "red" : "0.051"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

---

## Testing the Colors

After adding all colors:

1. In your app, use colors like: `Color("Background")`
2. Test in **light mode**: Device Settings → Display → Light
3. Test in **dark mode**: Device Settings → Display → Dark
4. Colors should automatically adapt!

---

## Fallback for Missing Assets

If you don't want to set up asset catalog colors right away, the updated `Theme.swift` includes fallback colors:
- `Theme.DarkColors` - Original dark mode colors
- `Theme.LightColors` - New light mode colors

You can temporarily use these directly:
```swift
// Temporary fallback
let backgroundColor = colorScheme == .dark ? 
    Theme.DarkColors.background : 
    Theme.LightColors.background
```

But the proper way is to use the Asset Catalog approach with `Color("Background")`.
