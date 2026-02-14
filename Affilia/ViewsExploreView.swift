//
//  ExploreView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

/// Smart explore view that shows different marketplaces based on user role
struct ExploreView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        Group {
            if let currentUser = authManager.currentUser {
                if currentUser.role == .builder {
                    // Affiliates see available campaign contracts
                    GigMarketplaceView()
                } else {
                    // Companies see available affiliates to recruit
                    BuilderMarketplaceView()
                }
            } else {
                // Not logged in - show affiliates by default
                BuilderMarketplaceView()
            }
        }
    }
}

/// Marketplace view for companies to find and recruit affiliates
struct BuilderMarketplaceView: View {
    @State private var searchText = ""
    @State private var selectedSkillFilter: String?
    @State private var selectedAvailability: AvailabilityStatus?
    @State private var showingPostGig = false
    
    let freelancers = MockData.shared.sampleFreelancers
    
    var filteredFreelancers: [FreelancerProfile] {
        freelancers.filter { freelancer in
            let matchesSearch = searchText.isEmpty ||
                freelancer.handle.localizedCaseInsensitiveContains(searchText) ||
                freelancer.displayName.localizedCaseInsensitiveContains(searchText) ||
                freelancer.skills.contains { $0.localizedCaseInsensitiveContains(searchText) }
            
            let matchesSkill = selectedSkillFilter == nil ||
                freelancer.skills.contains(selectedSkillFilter!)
            
            let matchesAvailability = selectedAvailability == nil ||
                freelancer.availability == selectedAvailability
            
            return matchesSearch && matchesSkill && matchesAvailability
        }
    }
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("AFFILIATE DIRECTORY")
                                .font(Theme.Typography.h1)
                                .foregroundColor(Theme.Colors.accent)
                            
                            HStack(spacing: Theme.Spacing.xs) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 6, height: 6)
                                    .modifier(PulseAnimation())
                                
                                Text("LIVE - Verified affiliates open to campaigns")
                                    .font(Theme.Typography.tiny)
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    // Search bar
                    TerminalSearchBar(searchText: $searchText)
                        .padding(.horizontal, Theme.Spacing.md)
                    
                    // Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.Spacing.sm) {
                            FilterChip(
                                title: "All",
                                isSelected: selectedAvailability == nil,
                                action: { selectedAvailability = nil }
                            )
                            
                            ForEach(AvailabilityStatus.allCases, id: \.self) { status in
                                FilterChip(
                                    title: status.rawValue,
                                    isSelected: selectedAvailability == status,
                                    action: { selectedAvailability = status }
                                )
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    // Results count
                    FadeInView(delay: 0.1) {
                        HStack {
                            Text("> \(filteredFreelancers.count) affiliate(s) found")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            if filteredFreelancers.count > 0 {
                                Text("• Invite top partners")
                                    .font(Theme.Typography.tiny)
                                    .foregroundColor(Theme.Colors.accent)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    // Freelancer grid
                    if filteredFreelancers.isEmpty {
                        FadeInView(delay: 0.2) {
                            EmptyStateView(message: "no affiliates found. adjust your filters_")
                                .padding(.top, Theme.Spacing.xxl)
                        }
                    } else {
                        LazyVStack(spacing: Theme.Spacing.md) {
                            ForEach(Array(filteredFreelancers.enumerated()), id: \.element.id) { index, freelancer in
                                SlideInView(delay: Double(index) * 0.05) {
                                    NavigationLink(destination: FreelancerDetailView(freelancer: freelancer)) {
                                        AnimatedCard {
                                            FreelancerCard(freelancer: freelancer)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    Spacer(minLength: Theme.Spacing.xl)
                }
                .padding(.bottom, Theme.Spacing.md)
            }
            
            // Floating Action Button for posting campaign contracts
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showingPostGig = true
                    } label: {
                        HStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                            Text("POST CONTRACT")
                                .font(Theme.Typography.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(Theme.Colors.accent)
                        .cornerRadius(Theme.CornerRadius.large)
                        .shadow(color: Theme.Colors.accent.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.trailing, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.md)
                }
            }
        }
        .sheet(isPresented: $showingPostGig) {
            PostGigView()
        }
    }
}

struct TerminalSearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundColor(Theme.Colors.accent)
            
            TextField("", text: $searchText, prompt: Text("> search by channel, niche, handle_").foregroundColor(Theme.Colors.textSecondary))
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textPrimary)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
        }
        .padding(Theme.Spacing.sm)
        .background(Theme.Colors.surface)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
        )
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(Theme.Typography.tiny)
                .foregroundColor(isSelected ? Theme.Colors.background : Theme.Colors.accent)
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, Theme.Spacing.xs)
                .background(isSelected ? Theme.Colors.accent : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                )
                .cornerRadius(Theme.CornerRadius.small)
        }
    }
}

struct FreelancerCard: View {
    let freelancer: FreelancerProfile
    @State private var isShortlisted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            // Header with avatar and name
            HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                AvatarView(displayName: freelancer.displayName, size: 40)
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    HStack(spacing: Theme.Spacing.xs) {
                        Text(freelancer.displayName)
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        // X verified badge
                        if freelancer.xVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(Theme.Colors.accent)
                        }
                    }
                    
                    // X handle with follower count
                    HStack(spacing: Theme.Spacing.xs) {
                        Text(freelancer.handle)
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.accent)
                        
                        if freelancer.xFollowers > 0 {
                            Text("•")
                                .font(Theme.Typography.tiny)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            Text("\(formatFollowerCount(freelancer.xFollowers)) followers")
                                .font(Theme.Typography.tiny)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                StatusTag(status: freelancer.availability)
            }
            
            // Bio
            Text(freelancer.bio)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .lineLimit(2)
                .padding(.top, Theme.Spacing.xs)
            
            // Skills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.xs) {
                    ForEach(freelancer.skills.prefix(5), id: \.self) { skill in
                        SkillTag(skill: skill)
                    }
                }
            }
            
            // Stats and pricing
            HStack {
                StatBadge(icon: "checkmark.circle", value: "\(freelancer.projectsCompleted)")
                StatBadge(icon: "star.fill", value: String(format: "%.1f", freelancer.averageRating))
                
                Spacer()
                
                if let rate = freelancer.hourlyRate {
                    Text("$\(Int(rate))/campaign")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.accent)
                } else if let project = freelancer.projectBasedPricing {
                    Text("$\(Int(project))/launch")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.accent)
                }
            }
            .padding(.top, Theme.Spacing.xs)
            
            // Action buttons
            HStack(spacing: Theme.Spacing.sm) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "arrow.right.circle")
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                        Text("VIEW PROFILE")
                    }
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                            .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                    )
                }
                
                Button(action: { isShortlisted.toggle() }) {
                    Image(systemName: isShortlisted ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .foregroundColor(isShortlisted ? Theme.Colors.background : Theme.Colors.accent)
                        .padding(Theme.Spacing.sm)
                        .background(isShortlisted ? Theme.Colors.accent : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                        )
                        .cornerRadius(Theme.CornerRadius.small)
                }
            }
            .padding(.top, Theme.Spacing.sm)
        }
        .padding(Theme.Spacing.md)
        .terminalCard()
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

struct StatBadge: View {
    let icon: String
    let value: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .regular, design: .monospaced))
            Text(value)
                .font(Theme.Typography.tiny)
        }
        .foregroundColor(Theme.Colors.textSecondary)
    }
}

struct EmptyStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Text(message)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
            
            BlinkingCursor()
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.xl)
    }
}

#Preview("Builder Marketplace (Hirers)") {
    NavigationStack {
        BuilderMarketplaceView()
    }
}
#Preview("Campaign Board (Affiliates)") {
    NavigationStack {
        GigMarketplaceView()
    }
}
