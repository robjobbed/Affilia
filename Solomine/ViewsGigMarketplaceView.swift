//
//  GigMarketplaceView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/4/26.
//

import SwiftUI

/// Marketplace view for affiliates to discover campaign contracts
struct GigMarketplaceView: View {
    @StateObject private var gigManager = GigManager.shared
    @State private var searchText = ""
    @State private var selectedCategory: GigCategory?
    @State private var selectedUrgency: GigUrgency?
    @State private var sortBy: GigSortOption = .newest
    @State private var selectedGig: GigListing?
    @State private var showingGigDetail = false
    
    var filteredGigs: [GigListing] {
        var gigs = gigManager.availableGigs
        
        // Search filter
        if !searchText.isEmpty {
            gigs = gigs.filter { gig in
                gig.title.localizedCaseInsensitiveContains(searchText) ||
                gig.description.localizedCaseInsensitiveContains(searchText) ||
                gig.requirements.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Category filter
        if let category = selectedCategory {
            gigs = gigs.filter { $0.category == category }
        }
        
        // Urgency filter
        if let urgency = selectedUrgency {
            gigs = gigs.filter { $0.urgency == urgency }
        }
        
        // Sort
        switch sortBy {
        case .newest:
            gigs.sort { $0.postedDate > $1.postedDate }
        case .highestBudget:
            gigs.sort { $0.budget > $1.budget }
        case .leastCompetitive:
            gigs.sort { $0.applicants < $1.applicants }
        }
        
        return gigs
    }
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    // Header with live indicator
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("CAMPAIGN CONTRACT BOARD")
                                .font(Theme.Typography.h1)
                                .foregroundColor(Theme.Colors.accent)
                            
                            HStack(spacing: Theme.Spacing.xs) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 6, height: 6)
                                    .modifier(PulseAnimation())
                                
                                Text("LIVE - New contracts every minute")
                                    .font(Theme.Typography.tiny)
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            gigManager.loadGigs()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .regular, design: .monospaced))
                                .foregroundColor(Theme.Colors.accent)
                                .rotationEffect(.degrees(gigManager.isLoading ? 360 : 0))
                                .animation(gigManager.isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: gigManager.isLoading)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    // Search bar
                    TerminalSearchBar(searchText: $searchText)
                        .padding(.horizontal, Theme.Spacing.md)
                    
                    // Sort options
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.Spacing.sm) {
                            Text("SORT:")
                                .font(Theme.Typography.tiny)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            ForEach(GigSortOption.allCases, id: \.self) { option in
                                Button {
                                    sortBy = option
                                } label: {
                                    Text(option.rawValue)
                                        .font(Theme.Typography.tiny)
                                        .foregroundColor(sortBy == option ? Theme.Colors.background : Theme.Colors.accent)
                                        .padding(.horizontal, Theme.Spacing.sm)
                                        .padding(.vertical, Theme.Spacing.xs)
                                        .background(sortBy == option ? Theme.Colors.accent : Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                                        )
                                        .cornerRadius(Theme.CornerRadius.small)
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    // Category filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.Spacing.sm) {
                            FilterChip(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            ForEach(GigCategory.allCases, id: \.self) { category in
                                FilterChip(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    // Urgency filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.Spacing.sm) {
                            Text("PRIORITY:")
                                .font(Theme.Typography.tiny)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            FilterChip(
                                title: "All",
                                isSelected: selectedUrgency == nil,
                                action: { selectedUrgency = nil }
                            )
                            
                            ForEach(GigUrgency.allCases, id: \.self) { urgency in
                                FilterChip(
                                    title: urgency.rawValue,
                                    isSelected: selectedUrgency == urgency,
                                    action: { selectedUrgency = urgency }
                                )
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    // Results count
                    FadeInView(delay: 0.1) {
                        HStack {
                            Text("> \(filteredGigs.count) contract(s) available")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            if filteredGigs.count > 0 {
                                Text("• Apply before slots fill")
                                    .font(Theme.Typography.tiny)
                                    .foregroundColor(Theme.Colors.accent)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    // Gig listings
                    if filteredGigs.isEmpty {
                        FadeInView(delay: 0.2) {
                            EmptyStateView(message: "no campaign contracts found. adjust your filters_")
                                .padding(.top, Theme.Spacing.xxl)
                        }
                    } else {
                        LazyVStack(spacing: Theme.Spacing.md) {
                            ForEach(Array(filteredGigs.enumerated()), id: \.element.id) { index, gig in
                                SlideInView(delay: Double(index) * 0.03) {
                                    Button {
                                        selectedGig = gig
                                        showingGigDetail = true
                                    } label: {
                                        AnimatedCard {
                                            GigListingCard(gig: gig)
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
            .refreshable {
                gigManager.loadGigs()
            }
        }
        .sheet(isPresented: $showingGigDetail) {
            if let gig = selectedGig {
                GigDetailView(gig: gig)
            }
        }
        .onAppear {
            if gigManager.availableGigs.isEmpty {
                gigManager.loadGigs()
            }
        }
    }
}

// MARK: - Gig Card

struct GigListingCard: View {
    let gig: GigListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            // Header with urgency and time
            HStack {
                UrgencyBadge(urgency: gig.urgency)
                
                Spacer()
                
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "clock")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                    Text(gig.timeAgo)
                        .font(Theme.Typography.tiny)
                }
                .foregroundColor(Theme.Colors.textSecondary)
            }
            
            // Title
            Text(gig.title)
                .font(Theme.Typography.title)
                .foregroundColor(Theme.Colors.textPrimary)
                .fontWeight(.semibold)
                .lineLimit(2)
            
            // Company info
            HStack(spacing: Theme.Spacing.xs) {
                Text("Posted by")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Text(gig.hirerHandle)
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.accent)
            }
            
            // Description
            Text(gig.description)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .lineLimit(3)
                .padding(.top, Theme.Spacing.xs)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack(spacing: Theme.Spacing.xs) {
                    SkillTag(skill: gig.category.rawValue)
                    SkillTag(skill: gig.commissionType.rawValue)
                    
                    if gig.applicants > 0 {
                        HStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: "person.2")
                                .font(.system(size: 10, weight: .regular, design: .monospaced))
                            Text("\(gig.applicants)")
                                .font(Theme.Typography.tiny)
                        }
                        .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                
                HStack(spacing: Theme.Spacing.md) {
                    contractMeta(label: "COMMISSION", value: gig.commissionDisplay)
                    contractMeta(label: "COOKIE", value: "\(gig.cookieWindowDays)d")
                    contractMeta(label: "REGION", value: gig.targetRegion)
                }
            }
            
            Divider()
                .background(Theme.Colors.border)
                .padding(.vertical, Theme.Spacing.xs)
            
            // Bottom bar with payout and CTA
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("MAX MONTHLY PAYOUT")
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    Text("$\(Int(gig.budget))")
                        .font(Theme.Typography.title)
                        .foregroundColor(Theme.Colors.accent)
                        .fontWeight(.bold)
                }
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("RESPONSE SLA")
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    Text("\(gig.estimatedHours)h")
                        .font(Theme.Typography.small)
                        .foregroundColor(Theme.Colors.textPrimary)
                }
                .padding(.leading, Theme.Spacing.md)
                
                Spacer()
                
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                    Text("JOIN CONTRACT")
                        .font(Theme.Typography.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(Theme.Colors.accent)
            }
        }
        .padding(Theme.Spacing.md)
        .terminalCard()
    }
    
    @ViewBuilder
    private func contractMeta(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textSecondary)
            Text(value)
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textPrimary)
        }
    }
}

// MARK: - Supporting Views

struct UrgencyBadge: View {
    let urgency: GigUrgency
    
    var body: some View {
        Text(urgency.rawValue)
            .font(Theme.Typography.tiny)
            .foregroundColor(urgency == .urgent ? .white : Theme.Colors.textPrimary)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(urgency == .urgent ? Color.red : Theme.Colors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .stroke(urgency == .urgent ? Color.red : Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
            )
            .cornerRadius(Theme.CornerRadius.small)
    }
}

struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.3 : 1.0)
            .opacity(isPulsing ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear {
                isPulsing = true
            }
    }
}

enum GigSortOption: String, CaseIterable {
    case newest = "NEWEST"
    case highestBudget = "HIGHEST PAYOUT"
    case leastCompetitive = "LOW COMPETITION"
}

// MARK: - Preview

#Preview {
    GigMarketplaceView()
}
