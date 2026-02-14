//
//  SettingsView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

/// App settings view with theme picker and other preferences
struct SettingsView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var authManager = AuthenticationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Appearance Section
                        appearanceSection
                        
                        // Account Section
                        accountSection
                        
                        // About Section
                        aboutSection
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
            }
        }
    }
    
    // MARK: - Appearance Section
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            SettingsSectionHeader(title: "Appearance")
            
            VStack(spacing: Theme.Spacing.xs) {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    ThemeOptionButton(
                        theme: theme,
                        isSelected: themeManager.currentTheme == theme,
                        action: {
                            themeManager.setTheme(theme)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Account Section
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            SettingsSectionHeader(title: "Account")
            
            if let user = authManager.currentUser {
                VStack(spacing: Theme.Spacing.xs) {
                    // User info
                    SettingsRow(
                        icon: "person.fill",
                        title: user.email,
                        subtitle: user.role?.rawValue ?? "No role selected"
                    )
                    
                    // X Profile
                    if let profile = authManager.xProfile {
                        SettingsRow(
                            icon: "x.circle.fill",
                            title: "@\(profile.username)",
                            subtitle: "\(profile.followers) followers"
                        )
                    }
                    
                    // Sign Out Button
                    Button {
                        authManager.signOut()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left.square.fill")
                                .foregroundColor(.red)
                            Text("Sign Out")
                                .font(Theme.Typography.body)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.surface)
                        .cornerRadius(Theme.CornerRadius.medium)
                    }
                }
            }
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            SettingsSectionHeader(title: "About")
            
            VStack(spacing: Theme.Spacing.xs) {
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "Version",
                    subtitle: "1.0.0"
                )
                
                NavigationLink {
                    TermsOfServiceView()
                } label: {
                    SettingsRow(
                        icon: "doc.text.fill",
                        title: "Terms of Service",
                        hasChevron: true
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    SettingsRow(
                        icon: "hand.raised.fill",
                        title: "Privacy Policy",
                        hasChevron: true
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink {
                    ContactSupportView()
                } label: {
                    SettingsRow(
                        icon: "envelope.fill",
                        title: "Contact Support",
                        hasChevron: true
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Theme Option Button

private struct ThemeOptionButton: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Theme.Colors.accent : Theme.Colors.surface)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: theme.icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? Theme.Colors.background : Theme.Colors.textPrimary)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.rawValue)
                        .font(Theme.Typography.body.weight(.semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text(theme.description)
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(Theme.Colors.accent)
                }
            }
            .padding(Theme.Spacing.md)
            .background(
                isSelected ?
                Theme.Colors.accent.opacity(0.1) :
                Theme.Colors.surface
            )
            .cornerRadius(Theme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(
                        isSelected ? Theme.Colors.accent : Theme.Colors.border,
                        lineWidth: isSelected ? 2 : Theme.BorderWidth.thin
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Section Header

private struct SettingsSectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title.uppercased())
            .font(Theme.Typography.tiny.weight(.bold))
            .foregroundColor(Theme.Colors.textSecondary)
            .tracking(1.5)
    }
}

// MARK: - Settings Row

private struct SettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var hasChevron: Bool = false
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Theme.Colors.accent)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            if hasChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
