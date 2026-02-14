//
//  AgentMarketplaceView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI
internal import Combine

/// Main view for browsing and hiring AI agents
struct AgentMarketplaceView: View {
    @StateObject private var viewModel = AgentMarketplaceViewModel()
    @State private var selectedAgent: AgentListing?
    @State private var showingCreateListing = false
    @State private var searchText = ""
    @State private var selectedCategory: AgentCategory? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    Divider().background(Theme.Colors.border)
                    
                    // Search and filters
                    searchAndFilters
                    
                    // Agents grid
                    ScrollView {
                        VStack(spacing: Theme.Spacing.lg) {
                            // Featured agents
                            if !viewModel.featuredAgents.isEmpty {
                                featuredSection
                            }
                            
                            // All agents
                            agentGridSection
                        }
                        .padding(Theme.Spacing.md)
                    }
                }
            }
            .navigationTitle("Agent Marketplace")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedAgent) { agent in
                AgentDetailView(agent: agent)
            }
            .sheet(isPresented: $showingCreateListing) {
                CreateAgentListingView()
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("AI Agents for Hire")
                    .font(Theme.Typography.h2)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("Browse autonomous bots that can work for you")
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
            
            Button {
                showingCreateListing = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("List Agent")
                        .font(Theme.Typography.tiny.weight(.bold))
                }
                .foregroundColor(Theme.Colors.background)
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, Theme.Spacing.xs)
                .background(Theme.Colors.accent)
                .cornerRadius(Theme.CornerRadius.small)
            }
        }
        .padding(Theme.Spacing.md)
    }
    
    private var searchAndFilters: some View {
        VStack(spacing: Theme.Spacing.sm) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Theme.Colors.textSecondary)
                
                TextField("Search agents...", text: $searchText)
                    .textFieldStyle(.plain)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
            }
            .padding(Theme.Spacing.sm)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.CornerRadius.medium)
            
            // Category filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.xs) {
                    CategoryFilterChip(
                        title: "All",
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )
                    
                    ForEach(AgentCategory.allCases, id: \.self) { category in
                        CategoryFilterChip(
                            title: category.rawValue,
                            icon: category.icon,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
    }
    
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Featured Agents")
                    .font(Theme.Typography.body.weight(.bold))
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.md) {
                    ForEach(viewModel.featuredAgents) { agent in
                        FeaturedAgentCard(agent: agent) {
                            selectedAgent = agent
                        }
                    }
                }
            }
        }
    }
    
    private var agentGridSection: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: Theme.Spacing.md),
                GridItem(.flexible(), spacing: Theme.Spacing.md)
            ],
            spacing: Theme.Spacing.md
        ) {
            ForEach(filteredAgents) { agent in
                AgentCard(agent: agent) {
                    selectedAgent = agent
                }
            }
        }
    }
    
    private var filteredAgents: [AgentListing] {
        var agents = viewModel.agents
        
        // Filter by category
        if let category = selectedCategory {
            agents = agents.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            agents = agents.filter { agent in
                agent.name.localizedCaseInsensitiveContains(searchText) ||
                agent.description.localizedCaseInsensitiveContains(searchText) ||
                agent.tagline.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return agents
    }
}

// MARK: - Category Filter Chip

struct CategoryFilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption2)
                }
                Text(title)
                    .font(Theme.Typography.tiny)
            }
            .foregroundColor(isSelected ? Theme.Colors.background : Theme.Colors.textPrimary)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(isSelected ? Theme.Colors.accent : Theme.Colors.surface)
            .cornerRadius(Theme.CornerRadius.small)
        }
    }
}

// MARK: - Agent Card

struct AgentCard: View {
    let agent: AgentListing
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                // Header with verification badge
                HStack {
                    Image(systemName: agent.category.icon)
                        .foregroundColor(Theme.Colors.accent)
                    
                    Spacer()
                    
                    if agent.verificationStatus == .verified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                // Agent name
                Text(agent.name)
                    .font(Theme.Typography.body.weight(.bold))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineLimit(1)
                
                // Tagline
                Text(agent.tagline)
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineLimit(2)
                    .frame(minHeight: 32, alignment: .topLeading)
                
                Divider().background(Theme.Colors.border)
                
                // Stats
                HStack(spacing: Theme.Spacing.xs) {
                    StatsItem(
                        icon: "star.fill",
                        value: String(format: "%.1f", agent.averageRating),
                        color: .yellow
                    )
                    
                    StatsItem(
                        icon: "checkmark.circle.fill",
                        value: "\(agent.totalHires)",
                        color: .green
                    )
                }
                
                // Pricing
                Text(agent.pricingModel.shortDisplay)
                    .font(Theme.Typography.body.weight(.bold))
                    .foregroundColor(Theme.Colors.accent)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Featured Agent Card

struct FeaturedAgentCard: View {
    let agent: AgentListing
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                // Featured badge
                HStack {
                    Label("Featured", systemImage: "star.fill")
                        .font(Theme.Typography.tiny)
                        .foregroundColor(.yellow)
                    
                    Spacer()
                    
                    if agent.verificationStatus == .verified {
                        Text("✓ Verified")
                            .font(Theme.Typography.tiny)
                            .foregroundColor(.blue)
                    }
                }
                
                // Agent info
                Text(agent.name)
                    .font(Theme.Typography.h3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(agent.tagline)
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineLimit(2)
                
                // Performance
                HStack(spacing: Theme.Spacing.md) {
                    PerformanceMetric(
                        label: "Success",
                        value: agent.performanceMetrics.successRatePercentage,
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    PerformanceMetric(
                        label: "Tasks",
                        value: "\(agent.performanceMetrics.tasksCompleted)",
                        icon: "bolt.fill",
                        color: .orange
                    )
                    
                    PerformanceMetric(
                        label: "Uptime",
                        value: agent.performanceMetrics.uptimePercentage,
                        icon: "antenna.radiowaves.left.and.right",
                        color: .blue
                    )
                }
                
                Divider().background(Theme.Colors.border)
                
                // Pricing
                HStack {
                    Text(agent.pricingModel.displayText)
                        .font(Theme.Typography.body.weight(.bold))
                        .foregroundColor(Theme.Colors.accent)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(Theme.Colors.accent)
                }
            }
            .padding(Theme.Spacing.md)
            .frame(width: 300)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(Theme.Colors.accent.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Helper Views

struct StatsItem: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            Text(value)
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
}

struct PerformanceMetric: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundColor(color)
                Text(label)
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            Text(value)
                .font(Theme.Typography.small.weight(.bold))
                .foregroundColor(Theme.Colors.textPrimary)
        }
    }
}

// MARK: - View Model

@MainActor
class AgentMarketplaceViewModel: ObservableObject {
    @Published var agents: [AgentListing] = AgentListing.samples
    @Published var featuredAgents: [AgentListing] = []
    
    init() {
        loadAgents()
    }
    
    func loadAgents() {
        // In production, fetch from API
        agents = AgentListing.samples
        
        // Featured agents are those with featuredUntil date
        featuredAgents = agents.filter { agent in
            if let featuredUntil = agent.featuredUntil {
                return featuredUntil > Date()
            }
            return false
        }
        
        // If no featured, show top rated
        if featuredAgents.isEmpty {
            featuredAgents = agents.sorted { $0.averageRating > $1.averageRating }.prefix(3).map { $0 }
        }
    }
}

#Preview {
    AgentMarketplaceView()
}
