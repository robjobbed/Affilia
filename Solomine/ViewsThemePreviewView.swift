//
//  ThemePreviewView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

/// Preview view showing light and dark themes side-by-side
struct ThemePreviewView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                Text("Theme Preview")
                    .font(Theme.Typography.h1)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                // Show both themes
                HStack(spacing: Theme.Spacing.md) {
                    // Dark Mode Preview
                    VStack(spacing: Theme.Spacing.sm) {
                        Text("Dark Mode 🌙")
                            .font(Theme.Typography.body.weight(.bold))
                        
                        ThemeColorGrid()
                            .preferredColorScheme(.dark)
                    }
                    
                    // Light Mode Preview
                    VStack(spacing: Theme.Spacing.sm) {
                        Text("Light Mode ☀️")
                            .font(Theme.Typography.body.weight(.bold))
                        
                        ThemeColorGrid()
                            .preferredColorScheme(.light)
                    }
                }
                
                // Current theme indicator
                ThemeIndicator()
            }
            .padding(Theme.Spacing.lg)
        }
        .background(Theme.Colors.background)
    }
}

// MARK: - Theme Color Grid

struct ThemeColorGrid: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            ColorSwatch(name: "Background", color: Theme.Colors.background)
            ColorSwatch(name: "Surface", color: Theme.Colors.surface)
            ColorSwatch(name: "Text Primary", color: Theme.Colors.textPrimary)
            ColorSwatch(name: "Text Secondary", color: Theme.Colors.textSecondary)
            ColorSwatch(name: "Accent", color: Theme.Colors.accent)
            ColorSwatch(name: "Border", color: Theme.Colors.border)
        }
        .padding(Theme.Spacing.sm)
        .background(Theme.Colors.background)
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

struct ColorSwatch: View {
    let name: String
    let color: Color
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Theme.Colors.border, lineWidth: 1)
                )
            
            Text(name)
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Spacer()
        }
    }
}

// MARK: - Theme Indicator

struct ThemeIndicator: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text("Current Configuration")
                .font(Theme.Typography.body.weight(.bold))
                .foregroundColor(Theme.Colors.textPrimary)
            
            HStack(spacing: Theme.Spacing.md) {
                ThemeInfoCard(
                    title: "Theme Setting",
                    value: themeManager.currentTheme.rawValue,
                    icon: themeManager.currentTheme.icon
                )
                
                ThemeInfoCard(
                    title: "Active Appearance",
                    value: colorScheme == .dark ? "Dark" : "Light",
                    icon: colorScheme == .dark ? "moon.fill" : "sun.max.fill"
                )
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

struct ThemeInfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(Theme.Colors.accent)
            
            Text(value)
                .font(Theme.Typography.body.weight(.bold))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text(title)
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.sm)
        .background(Theme.Colors.background)
        .cornerRadius(Theme.CornerRadius.small)
    }
}

// MARK: - Preview Sample View

struct ThemePreviewSampleView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Header
            Text("Sample Interface")
                .font(Theme.Typography.h2)
                .foregroundColor(Theme.Colors.textPrimary)
            
            // Card
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Card Title")
                    .font(Theme.Typography.body.weight(.bold))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("This is some sample text to show how the theme looks in a real interface component.")
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Divider()
                    .background(Theme.Colors.border)
                
                HStack {
                    Button("Cancel") {
                        // Action
                    }
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.textSecondary)
                    
                    Spacer()
                    
                    Button("Confirm") {
                        // Action
                    }
                    .font(Theme.Typography.small.weight(.bold))
                    .foregroundColor(Theme.Colors.background)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.xs)
                    .background(Theme.Colors.accent)
                    .cornerRadius(Theme.CornerRadius.small)
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
            )
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.background)
    }
}

#Preview("Theme Preview") {
    ThemePreviewView()
}

#Preview("Dark Mode Sample") {
    ThemePreviewSampleView()
        .preferredColorScheme(.dark)
}

#Preview("Light Mode Sample") {
    ThemePreviewSampleView()
        .preferredColorScheme(.light)
}
