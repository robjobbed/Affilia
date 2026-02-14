//
//  ProfileView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct ProfileView: View {
    let user = MockData.shared.currentUser
    @State private var showingSettings = false
    @State private var showingEditProfile = false
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Header
                    HStack {
                        TerminalHeader(title: "Profile")
                        Spacer()
                        Button(action: { showingSettings.toggle() }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 18, weight: .regular, design: .monospaced))
                                .foregroundColor(Theme.Colors.accent)
                        }
                        .padding(.trailing, Theme.Spacing.md)
                    }
                    
                    // User info
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                        .fill(Theme.Colors.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                                        )
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "person")
                                        .font(.system(size: 18, weight: .regular, design: .monospaced))
                                        .foregroundColor(Theme.Colors.accent)
                                }
                                
                                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                    Text(user.email)
                                        .font(Theme.Typography.body)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                    
                                    if let role = user.role {
                                        Text(role.displayTitle)
                                            .font(Theme.Typography.caption)
                                            .foregroundColor(Theme.Colors.accent)
                                            .padding(.horizontal, Theme.Spacing.sm)
                                            .padding(.vertical, Theme.Spacing.xs)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                    .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                                            )
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(Theme.Spacing.md)
                        .terminalCard()
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    // Quick stats
                    if user.role == .builder {
                        BuilderProfileStats()
                    } else {
                        ClientProfileStats()
                    }
                    
                    // Action buttons
                    VStack(spacing: Theme.Spacing.sm) {
                        NavigationLink(destination: ConnectedAccountsView()) {
                            HStack {
                                Image(systemName: "link")
                                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                                Text("CONNECTED ACCOUNTS")
                            }
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.accent)
                            .padding(.horizontal, Theme.Spacing.md)
                            .padding(.vertical, Theme.Spacing.sm)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                    .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                            )
                            .cornerRadius(Theme.CornerRadius.medium)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { showingEditProfile.toggle() }) {
                            HStack {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                                Text("EDIT PROFILE")
                            }
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.accent)
                            .padding(.horizontal, Theme.Spacing.md)
                            .padding(.vertical, Theme.Spacing.sm)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                    .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                            )
                            .cornerRadius(Theme.CornerRadius.medium)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if user.role == .builder {
                            TerminalButton("MANAGE CONTRACTS") {}
                        }
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                                Text("LOG OUT")
                            }
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.accentSecondary)
                            .padding(.horizontal, Theme.Spacing.md)
                            .padding(.vertical, Theme.Spacing.sm)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                    .stroke(Theme.Colors.accentSecondary, lineWidth: Theme.BorderWidth.thin)
                            )
                            .cornerRadius(Theme.CornerRadius.medium)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    Spacer(minLength: Theme.Spacing.xl)
                }
                .padding(.bottom, Theme.Spacing.md)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
                .environmentObject(authManager)
        }
    }
}

struct BuilderProfileStats: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            SectionHeader("Your Stats")
            
            VStack(spacing: Theme.Spacing.sm) {
                ProfileStatRow(label: "CAMPAIGNS COMPLETED", value: "47")
                ProfileStatRow(label: "AVERAGE RATING", value: "4.9")
                ProfileStatRow(label: "TOTAL COMMISSIONS", value: "$12,500")
                ProfileStatRow(label: "ACTIVE CONTRACTS", value: "3")
            }
            .padding(.horizontal, Theme.Spacing.md)
        }
    }
}

struct ClientProfileStats: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            SectionHeader("Your Activity")
            
            VStack(spacing: Theme.Spacing.sm) {
                ProfileStatRow(label: "SHORTLISTED AFFILIATES", value: "2")
                ProfileStatRow(label: "LIVE CONTRACTS", value: "4")
                ProfileStatRow(label: "COMPLETED CONTRACTS", value: "12")
                ProfileStatRow(label: "TOTAL PAYOUTS", value: "$48,500")
            }
            .padding(.horizontal, Theme.Spacing.md)
        }
    }
}

struct ProfileStatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.accent)
        }
        .padding(Theme.Spacing.sm)
        .terminalCard()
    }
}

struct LegacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pushNotifications = true
    @State private var emailNotifications = false
    @State private var messageAlerts = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        // Notifications section
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            SectionHeader("Notifications")
                            
                            VStack(spacing: Theme.Spacing.sm) {
                                SettingsToggleRow(
                                    title: "PUSH NOTIFICATIONS",
                                    isOn: $pushNotifications
                                )
                                
                                SettingsToggleRow(
                                    title: "EMAIL NOTIFICATIONS",
                                    isOn: $emailNotifications
                                )
                                
                                SettingsToggleRow(
                                    title: "MESSAGE ALERTS",
                                    isOn: $messageAlerts
                                )
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                        }
                        
                        // Appearance section
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            SectionHeader("Appearance")
                            
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("> dark mode only. no compromises.")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .padding(Theme.Spacing.md)
                                    .terminalCard()
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                        }
                        
                        // About section
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            SectionHeader("About")
                            
                            VStack(spacing: Theme.Spacing.sm) {
                                SettingsInfoRow(label: "VERSION", value: "1.0.0")
                                SettingsInfoRow(label: "BUILD", value: "2026.02.03")
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                        }
                        
                        Spacer(minLength: Theme.Spacing.xl)
                    }
                    .padding(.vertical, Theme.Spacing.md)
                }
            }
            .navigationTitle("SETTINGS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SETTINGS")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.accent)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .foregroundColor(Theme.Colors.accent)
                    }
                }
            }
            .toolbarBackground(Theme.Colors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}

struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Theme.Colors.accent)
        }
        .padding(Theme.Spacing.sm)
        .terminalCard()
    }
}

struct SettingsInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textPrimary)
        }
        .padding(Theme.Spacing.sm)
        .terminalCard()
    }
}

#Preview {
    ProfileView()
}
