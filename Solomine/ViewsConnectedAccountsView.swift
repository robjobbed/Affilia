//
//  ConnectedAccountsView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct ConnectedAccountsView: View {
    @State private var authManager = AuthenticationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // X Account
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        SectionHeader("X (Twitter) Account", icon: "bird")
                        
                        if let xProfile = authManager.xProfile {
                            // Connected X account
                            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                                HStack(spacing: Theme.Spacing.sm) {
                                    // Avatar placeholder
                                    ZStack {
                                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                            .fill(Theme.Colors.surface)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                    .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                                            )
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "bird.fill")
                                            .font(.system(size: 24, design: .monospaced))
                                            .foregroundColor(Theme.Colors.accent)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                        HStack(spacing: Theme.Spacing.xs) {
                                            Text(xProfile.displayName)
                                                .font(Theme.Typography.body)
                                                .foregroundColor(Theme.Colors.textPrimary)
                                            
                                            if xProfile.verified {
                                                Image(systemName: "checkmark.seal.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Theme.Colors.accent)
                                            }
                                        }
                                        
                                        Text("@\(xProfile.username)")
                                            .font(Theme.Typography.caption)
                                            .foregroundColor(Theme.Colors.accent)
                                    }
                                    
                                    Spacer()
                                    
                                    // Status badge
                                    Text("CONNECTED")
                                        .font(Theme.Typography.tiny)
                                        .foregroundColor(Theme.Colors.accent)
                                        .padding(.horizontal, Theme.Spacing.xs)
                                        .padding(.vertical, 2)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                                        )
                                }
                                
                                // Stats
                                HStack(spacing: Theme.Spacing.md) {
                                    StatBadge(icon: "person.2", value: "\(xProfile.followers)")
                                    StatBadge(icon: "arrow.right", value: "\(xProfile.following)")
                                }
                                
                                // Actions
                                HStack(spacing: Theme.Spacing.sm) {
                                    Button(action: { /* View profile */ }) {
                                        Text("VIEW ON X")
                                            .font(Theme.Typography.tiny)
                                            .foregroundColor(Theme.Colors.accent)
                                            .padding(.horizontal, Theme.Spacing.sm)
                                            .padding(.vertical, Theme.Spacing.xs)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                    .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                                            )
                                    }
                                    
                                    Button(action: { /* Sync */ }) {
                                        HStack(spacing: Theme.Spacing.xs) {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                                .font(.system(size: 10, weight: .regular, design: .monospaced))
                                            Text("SYNC")
                                        }
                                        .font(Theme.Typography.tiny)
                                        .foregroundColor(Theme.Colors.accent)
                                        .padding(.horizontal, Theme.Spacing.sm)
                                        .padding(.vertical, Theme.Spacing.xs)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                                        )
                                    }
                                }
                            }
                            .padding(Theme.Spacing.md)
                            .terminalCard()
                        } else {
                            // Not connected
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("> x account not connected")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                Text("Connect your X account to import your profile, showcase your following, and build credibility.")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .lineSpacing(4)
                                
                                Button(action: { authManager.signInWithX() }) {
                                    HStack {
                                        Image(systemName: "bird")
                                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                                        Text("CONNECT X ACCOUNT")
                                    }
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.background)
                                    .padding(.vertical, Theme.Spacing.sm)
                                    .frame(maxWidth: .infinity)
                                    .background(Theme.Colors.accent)
                                    .cornerRadius(Theme.CornerRadius.small)
                                }
                            }
                            .padding(Theme.Spacing.md)
                            .terminalCard()
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    // GitHub Account
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        SectionHeader("GitHub Account", icon: "chevron.left.forwardslash.chevron.right")
                        
                        if let githubProfile = authManager.githubProfile {
                            // Connected GitHub account
                            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                                HStack(spacing: Theme.Spacing.sm) {
                                    // Avatar placeholder
                                    ZStack {
                                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                            .fill(Theme.Colors.surface)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                    .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                                            )
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                                            .font(.system(size: 20, design: .monospaced))
                                            .foregroundColor(Theme.Colors.accent)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                        Text(githubProfile.name ?? githubProfile.username)
                                            .font(Theme.Typography.body)
                                            .foregroundColor(Theme.Colors.textPrimary)
                                        
                                        Text("@\(githubProfile.username)")
                                            .font(Theme.Typography.caption)
                                            .foregroundColor(Theme.Colors.accent)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("CONNECTED")
                                        .font(Theme.Typography.tiny)
                                        .foregroundColor(Theme.Colors.accent)
                                        .padding(.horizontal, Theme.Spacing.xs)
                                        .padding(.vertical, 2)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                                        )
                                }
                                
                                // Stats
                                HStack(spacing: Theme.Spacing.md) {
                                    StatBadge(icon: "folder", value: "\(githubProfile.publicRepos)")
                                    StatBadge(icon: "star", value: "\(githubProfile.followers)")
                                }
                                
                                // Actions
                                HStack(spacing: Theme.Spacing.sm) {
                                    Button(action: { /* View profile */ }) {
                                        Text("VIEW ON GITHUB")
                                            .font(Theme.Typography.tiny)
                                            .foregroundColor(Theme.Colors.accent)
                                            .padding(.horizontal, Theme.Spacing.sm)
                                            .padding(.vertical, Theme.Spacing.xs)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                    .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                                            )
                                    }
                                    
                                    Button(action: { /* Import repos */ }) {
                                        HStack(spacing: Theme.Spacing.xs) {
                                            Image(systemName: "arrow.down.circle")
                                                .font(.system(size: 10, weight: .regular, design: .monospaced))
                                            Text("IMPORT REPOS")
                                        }
                                        .font(Theme.Typography.tiny)
                                        .foregroundColor(Theme.Colors.accent)
                                        .padding(.horizontal, Theme.Spacing.sm)
                                        .padding(.vertical, Theme.Spacing.xs)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                                        )
                                    }
                                }
                            }
                            .padding(Theme.Spacing.md)
                            .terminalCard()
                        } else {
                            // Not connected
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("> github not connected")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                Text("Link your GitHub to automatically import your repositories as portfolio projects and showcase your code.")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .lineSpacing(4)
                                
                                Button(action: { authManager.linkGitHub() }) {
                                    HStack {
                                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                                        Text("CONNECT GITHUB")
                                    }
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.accent)
                                    .padding(.vertical, Theme.Spacing.sm)
                                    .frame(maxWidth: .infinity)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                            .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                                    )
                                    .cornerRadius(Theme.CornerRadius.small)
                                }
                            }
                            .padding(Theme.Spacing.md)
                            .terminalCard()
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    // Info section
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        SectionHeader("Why Connect?")
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            InfoItem(text: "Build instant credibility with your X following")
                            InfoItem(text: "Auto-import GitHub repos to your portfolio")
                            InfoItem(text: "Showcase your real development work")
                            InfoItem(text: "Sync profile updates automatically")
                        }
                        .padding(Theme.Spacing.md)
                        .terminalCard()
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    Spacer(minLength: Theme.Spacing.xl)
                }
                .padding(.vertical, Theme.Spacing.md)
            }
        }
        .navigationTitle("CONNECTED ACCOUNTS")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("CONNECTED ACCOUNTS")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.accent)
            }
        }
        .toolbarBackground(Theme.Colors.surface, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct InfoItem: View {
    let text: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Text(">")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.accent)
            
            Text(text)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        ConnectedAccountsView()
    }
}
