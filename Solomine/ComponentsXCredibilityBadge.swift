//
//  XCredibilityBadge.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

/// Shows X verification and follower count for credibility
struct XCredibilityBadge: View {
    let freelancer: FreelancerProfile
    let showFollowers: Bool
    
    init(freelancer: FreelancerProfile, showFollowers: Bool = true) {
        self.freelancer = freelancer
        self.showFollowers = showFollowers
    }
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            // X verified badge
            if freelancer.xVerified {
                HStack(spacing: 2) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.Colors.accent)
                    Text("VERIFIED")
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.accent)
                }
                .padding(.horizontal, Theme.Spacing.xs)
                .padding(.vertical, 2)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                )
            }
            
            // Follower count
            if showFollowers && freelancer.xFollowers > 0 {
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "person.2")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                    Text(formatFollowerCount(freelancer.xFollowers))
                        .font(Theme.Typography.tiny)
                }
                .foregroundColor(Theme.Colors.textSecondary)
                .padding(.horizontal, Theme.Spacing.xs)
                .padding(.vertical, 2)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
                )
            }
        }
    }
    
    private func formatFollowerCount(_ count: Int) -> String {
        if count >= 1000000 {
            return String(format: "%.1fM", Double(count) / 1000000.0)
        } else if count >= 1000 {
            return String(format: "%.1fK", Double(count) / 1000.0)
        } else {
            return "\(count)"
        }
    }
}

/// Prominent X link button
struct ViewOnXButton: View {
    let xUsername: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "bird.fill")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                Text("VIEW ON X")
            }
            .font(Theme.Typography.caption)
            .foregroundColor(Theme.Colors.accent)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
            )
            .cornerRadius(Theme.CornerRadius.small)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        XCredibilityBadge(
            freelancer: FreelancerProfile(
                xUsername: "robcodes",
                displayName: "Rob",
                bio: "Test",
                skills: [],
                xFollowers: 5420,
                xVerified: false
            )
        )
        
        XCredibilityBadge(
            freelancer: FreelancerProfile(
                xUsername: "cybervoid",
                displayName: "Alex",
                bio: "Test",
                skills: [],
                xFollowers: 12300,
                xVerified: true
            )
        )
        
        ViewOnXButton(xUsername: "robcodes", action: {})
    }
    .padding()
    .background(Theme.Colors.background)
}
