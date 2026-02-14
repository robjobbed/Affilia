//
//  Theme.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

/// Centralized theme configuration for the Affilia hacker terminal aesthetic
struct Theme {
    
    // MARK: - Colors
    
    /// Dynamic colors that adapt to light/dark mode
    struct Colors {
        // MARK: - Background Colors
        
        /// Deep rich black background (dark) / Clean white (light)
        static var background: Color {
            DarkColors.background
        }
        
        /// Slightly elevated surface for layering
        static var backgroundElevated: Color {
            DarkColors.backgroundElevated
        }
        
        /// Dark warm grey for cards and containers (dark) / Light grey (light)
        static var surface: Color {
            DarkColors.surface
        }
        
        /// Subtle border color
        static var border: Color {
            DarkColors.border
        }
        
        // MARK: - Text Colors
        
        /// Primary text color - warm off-white (dark) / Dark grey (light)
        static var textPrimary: Color {
            DarkColors.textPrimary
        }
        
        /// Secondary text color - muted warm grey
        static var textSecondary: Color {
            DarkColors.textSecondary
        }
        
        // MARK: - Accent Colors
        
        /// Muted olive green - primary accent (consistent in both modes)
        static var accent: Color {
            DarkColors.accent
        }
        
        /// Softer sage green for terminal/code elements
        static var terminalGreen: Color {
            DarkColors.terminalGreen
        }
        
        /// Warm amber - secondary accent for highlights
        static var accentSecondary: Color {
            DarkColors.accentSecondary
        }
        
        /// Dimmed version of accent for disabled states
        static var accentDimmed: Color {
            accent.opacity(0.4)
        }
        
        /// Subtle glow color for interactive elements
        static var glow: Color {
            accent.opacity(0.15)
        }
    }
    
    // MARK: - Legacy Colors (for backwards compatibility)
    
    /// Legacy dark mode colors (kept for reference)
    struct DarkColors {
        static let background = Color(hex: "0D0D0D")
        static let backgroundElevated = Color(hex: "141414")
        static let surface = Color(hex: "1A1A1A")
        static let border = Color(hex: "2A2A2A")
        static let textPrimary = Color(hex: "E8E6E3")
        static let textSecondary = Color(hex: "8A8A7A")
        static let accent = Color(hex: "9BAA7F")
        static let terminalGreen = Color(hex: "7A8F6C")
        static let accentSecondary = Color(hex: "C9A961")
    }
    
    /// Light mode colors
    struct LightColors {
        static let background = Color(hex: "FFFFFF")
        static let backgroundElevated = Color(hex: "F8F8F8")
        static let surface = Color(hex: "F5F5F5")
        static let border = Color(hex: "E0E0E0")
        static let textPrimary = Color(hex: "1A1A1A")
        static let textSecondary = Color(hex: "666666")
        static let accent = Color(hex: "9BAA7F") // Same accent in both modes
        static let terminalGreen = Color(hex: "7A8F6C")
        static let accentSecondary = Color(hex: "C9A961")
    }
    
    // MARK: - Typography
    struct Typography {
        /// Monospace font for body text
        static let body = Font.custom("Menlo", size: 14)
        
        /// Monospace font for small text
        static let small = Font.custom("Menlo", size: 12)
        
        /// Monospace font for caption
        static let caption = Font.custom("Menlo", size: 12)
        
        /// Monospace font for tiny text
        static let tiny = Font.custom("Menlo", size: 10)
        
        /// Monospace font for large display text
        static let h1 = Font.custom("Menlo", size: 28).weight(.bold)
        
        /// Monospace font for section headings
        static let h2 = Font.custom("Menlo", size: 22).weight(.bold)
        
        /// Monospace font for subsection headings
        static let h3 = Font.custom("Menlo", size: 18).weight(.bold)
        
        /// Monospace font for headings (legacy)
        static let heading = Font.custom("Menlo", size: 18).weight(.bold)
        
        /// Monospace font for large headings (legacy)
        static let headingLarge = Font.custom("Menlo", size: 24).weight(.bold)
        
        /// Monospace font for section titles
        static let title = Font.custom("Menlo", size: 16).weight(.semibold)
        
        /// Letter spacing for headers
        static let headerLetterSpacing: CGFloat = 2.0
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 2
        static let medium: CGFloat = 4
        static let large: CGFloat = 8
        static let none: CGFloat = 0
    }
    
    // MARK: - Border Width
    struct BorderWidth {
        static let thin: CGFloat = 1
        static let medium: CGFloat = 2
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions for Theme
extension View {
    /// Applies terminal card styling
    func terminalCard() -> some View {
        self
            .background(Theme.Colors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
            )
            .cornerRadius(Theme.CornerRadius.medium)
    }
    
    /// Applies terminal button styling (outlined)
    func terminalButton(isActive: Bool = false) -> some View {
        self
            .foregroundColor(isActive ? Theme.Colors.background : Theme.Colors.accent)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(isActive ? Theme.Colors.accent : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
            )
            .cornerRadius(Theme.CornerRadius.medium)
    }
}
