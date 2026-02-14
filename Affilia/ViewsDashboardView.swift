//
//  DashboardView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        Group {
            if authManager.currentUser?.role == .builder {
                // Affiliate dashboard
                FreelancerDashboardView()
            } else {
                // Company dashboard
                HirerDashboardView()
            }
        }
    }
}

// MARK: - Hirer Dashboard

struct HirerDashboardView: View {
    let user = MockData.shared.currentUser
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Header
                    TerminalHeader(title: "Company Dashboard")
                    
                    ClientDashboard()
                    
                    Spacer(minLength: Theme.Spacing.xl)
                }
                .padding(.bottom, Theme.Spacing.md)
            }
        }
    }
}

struct FreelancerDashboard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Stats overview
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                SectionHeader("Overview")
                
                HStack(spacing: Theme.Spacing.md) {
                    DashboardStatCard(
                        title: "ACTIVE CONTRACTS",
                        value: "3",
                        icon: "megaphone"
                    )
                    
                    DashboardStatCard(
                        title: "PENDING",
                        value: "2",
                        icon: "clock"
                    )
                }
                .padding(.horizontal, Theme.Spacing.md)
                
                HStack(spacing: Theme.Spacing.md) {
                    DashboardStatCard(
                        title: "EARNINGS",
                        value: "$12.5k",
                        icon: "dollarsign.circle"
                    )
                    
                    DashboardStatCard(
                        title: "THIS MONTH",
                        value: "$3.2k",
                        icon: "chart.line.uptrend.xyaxis"
                    )
                }
                .padding(.horizontal, Theme.Spacing.md)
            }
            
            // Active requests
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                SectionHeader("Inbound Invites", icon: "envelope")
                
                Text("> 2 new invite(s)")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .padding(.horizontal, Theme.Spacing.md)
                
                VStack(spacing: Theme.Spacing.sm) {
                    RequestCard(
                        clientName: "NeonCart",
                        requestType: "Skincare creator affiliate contract",
                        timeAgo: "2h ago"
                    )
                    
                    RequestCard(
                        clientName: "FlowLedger",
                        requestType: "SaaS rev-share partner invite",
                        timeAgo: "5h ago"
                    )
                }
                .padding(.horizontal, Theme.Spacing.md)
            }
        }
    }
}

struct ClientDashboard: View {
    let shortlistedCount = MockData.shared.currentUser.shortlistedFreelancers.count
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Stats overview
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                SectionHeader("Overview")
                
                HStack(spacing: Theme.Spacing.md) {
                    DashboardStatCard(
                        title: "SHORTLISTED",
                        value: "\(shortlistedCount)",
                        icon: "bookmark"
                    )
                    
                    DashboardStatCard(
                        title: "LIVE CONTRACTS",
                        value: "4",
                        icon: "doc.text"
                    )
                }
                .padding(.horizontal, Theme.Spacing.md)
                
                HStack(spacing: Theme.Spacing.md) {
                    DashboardStatCard(
                        title: "PAYOUT COMMITTED",
                        value: "$42k",
                        icon: "dollarsign.circle"
                    )
                    
                    DashboardStatCard(
                        title: "ACTIVE AFFILIATES",
                        value: "28",
                        icon: "checkmark.circle"
                    )
                }
                .padding(.horizontal, Theme.Spacing.md)
            }
            
            // Shortlisted affiliates
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                SectionHeader("Shortlisted Affiliates", icon: "bookmark")
                
                if shortlistedCount == 0 {
                    Text("> no shortlisted affiliates yet_")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.vertical, Theme.Spacing.lg)
                } else {
                    VStack(spacing: Theme.Spacing.sm) {
                        ForEach(MockData.shared.sampleFreelancers.prefix(2)) { freelancer in
                            ShortlistCard(freelancer: freelancer)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                }
            }
            
            // Recent activity
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                SectionHeader("Recent Activity", icon: "clock")
                
                VStack(spacing: Theme.Spacing.sm) {
                    ClientActivityItem(
                        icon: "message",
                        text: "New application from @growthwithmaya",
                        timeAgo: "1h ago"
                    )
                    
                    ClientActivityItem(
                        icon: "checkmark.circle",
                        text: "Payout batch completed for AtlasTrips",
                        timeAgo: "2d ago"
                    )
                    
                    ClientActivityItem(
                        icon: "bookmark",
                        text: "Added @dealdojo to shortlist",
                        timeAgo: "3d ago"
                    )
                }
                .padding(.horizontal, Theme.Spacing.md)
            }
        }
    }
}

struct DashboardStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundColor(Theme.Colors.accent)
                Spacer()
            }
            
            Text(value)
                .font(Theme.Typography.headingLarge)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text(title)
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .terminalCard()
    }
}

struct RequestCard: View {
    let clientName: String
    let requestType: String
    let timeAgo: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Text(clientName)
                    .font(Theme.Typography.title)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Text("NEW")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.accent)
                    .padding(.horizontal, Theme.Spacing.xs)
                    .padding(.vertical, 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                            .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                    )
            }
            
            Text(requestType)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            HStack {
                Text(timeAgo)
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Spacer()
                
                Button(action: {}) {
                    Text("VIEW INVITE")
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.accent)
                }
            }
            .padding(.top, Theme.Spacing.xs)
        }
        .padding(Theme.Spacing.sm)
        .terminalCard()
    }
}

struct ShortlistCard: View {
    let freelancer: FreelancerProfile
    
    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            AvatarView(displayName: freelancer.displayName, size: 32)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(freelancer.handle)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.accent)
                
                Text(freelancer.skills.prefix(3).joined(separator: ", "))
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(Theme.Colors.accent)
            }
        }
        .padding(Theme.Spacing.sm)
        .terminalCard()
    }
}

struct ClientActivityItem: View {
    let icon: String
    let text: String
    let timeAgo: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(Theme.Colors.accent)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(timeAgo)
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(Theme.Spacing.sm)
        .terminalCard()
    }
}

#Preview {
    DashboardView()
}
