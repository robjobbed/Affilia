//
//  AgentDetailView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

/// Detailed view of an agent with ability to hire
struct AgentDetailView: View {
    let agent: AgentListing
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingHireSheet = false
    @State private var selectedTab: AgentDetailTab = .overview
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Agent header
                        agentHeader
                        
                        // Tab selector
                        tabSelector
                        
                        // Content based on selected tab
                        tabContent
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingHireSheet = true
                    } label: {
                        Text("Hire Agent")
                            .font(Theme.Typography.small.weight(.bold))
                            .foregroundColor(Theme.Colors.background)
                            .padding(.horizontal, Theme.Spacing.sm)
                            .padding(.vertical, Theme.Spacing.xs)
                            .background(Theme.Colors.accent)
                            .cornerRadius(Theme.CornerRadius.small)
                    }
                }
            }
            .sheet(isPresented: $showingHireSheet) {
                HireAgentView(agent: agent)
            }
        }
    }
    
    // MARK: - View Components
    
    private var agentHeader: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Category and verification
            HStack {
                Label(agent.category.rawValue, systemImage: agent.category.icon)
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.accent)
                
                Spacer()
                
                if agent.verificationStatus == .verified {
                    Label("Verified", systemImage: "checkmark.seal.fill")
                        .font(Theme.Typography.tiny)
                        .foregroundColor(.blue)
                }
            }
            
            // Agent name
            Text(agent.name)
                .font(Theme.Typography.h1)
                .foregroundColor(Theme.Colors.textPrimary)
            
            // Tagline
            Text(agent.tagline)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
            
            // Stats row
            HStack(spacing: Theme.Spacing.lg) {
                AgentStatCard(
                    icon: "star.fill",
                    value: String(format: "%.1f", agent.averageRating),
                    label: "Rating",
                    color: .yellow
                )
                
                AgentStatCard(
                    icon: "person.2.fill",
                    value: "\(agent.totalHires)",
                    label: "Hires",
                    color: .green
                )
                
                AgentStatCard(
                    icon: "bolt.fill",
                    value: "\(agent.performanceMetrics.tasksCompleted)",
                    label: "Tasks",
                    color: .orange
                )
            }
            
            // Pricing
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Pricing")
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Text(agent.pricingModel.displayText)
                    .font(Theme.Typography.h3)
                    .foregroundColor(Theme.Colors.accent)
            }
            .padding(Theme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.CornerRadius.medium)
            
            // Owner info
            HStack(spacing: Theme.Spacing.sm) {
                Circle()
                    .fill(Theme.Colors.accent.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(agent.ownerInfo.displayName.prefix(1))
                            .font(Theme.Typography.body.weight(.bold))
                            .foregroundColor(Theme.Colors.accent)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(agent.ownerInfo.displayName)
                            .font(Theme.Typography.small.weight(.bold))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        if agent.ownerInfo.xVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text(agent.ownerInfo.handle)
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                Text("\(agent.ownerInfo.totalAgentsListed) agents")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(AgentDetailTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(Theme.Typography.small)
                        .foregroundColor(selectedTab == tab ? Theme.Colors.accent : Theme.Colors.textSecondary)
                        .padding(.vertical, Theme.Spacing.sm)
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedTab == tab ?
                            Theme.Colors.accent.opacity(0.1) : Color.clear
                        )
                }
            }
        }
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.medium)
    }
    
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .overview:
            overviewTab
        case .capabilities:
            capabilitiesTab
        case .technical:
            technicalTab
        case .reviews:
            reviewsTab
        }
    }
    
    private var overviewTab: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Description
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("About")
                    .font(Theme.Typography.body.weight(.bold))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(agent.description)
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            // Performance metrics
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Performance")
                    .font(Theme.Typography.body.weight(.bold))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                VStack(spacing: Theme.Spacing.xs) {
                    PerformanceRow(
                        label: "Success Rate",
                        value: agent.performanceMetrics.successRatePercentage,
                        progress: agent.performanceMetrics.successRate,
                        color: .green
                    )
                    
                    PerformanceRow(
                        label: "Uptime",
                        value: agent.performanceMetrics.uptimePercentage,
                        progress: agent.performanceMetrics.uptime,
                        color: .blue
                    )
                    
                    HStack {
                        Text("Avg Response Time")
                            .font(Theme.Typography.small)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        Spacer()
                        
                        Text(agent.performanceMetrics.responseTimeDisplay)
                            .font(Theme.Typography.small.weight(.bold))
                            .foregroundColor(Theme.Colors.accent)
                    }
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.surface)
                .cornerRadius(Theme.CornerRadius.medium)
            }
        }
    }
    
    private var capabilitiesTab: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            ForEach(agent.capabilities) { capability in
                CapabilityCard(capability: capability)
            }
        }
    }
    
    private var technicalTab: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            TechnicalDetailRow(label: "Framework", value: agent.technicalDetails.framework)
            
            if let model = agent.technicalDetails.model {
                TechnicalDetailRow(label: "Model", value: model)
            }
            
            TechnicalDetailRow(label: "Hosting", value: agent.technicalDetails.hosting.rawValue)
            
            if let repo = agent.technicalDetails.repositoryURL {
                Link(destination: URL(string: repo)!) {
                    HStack {
                        Text("View Repository")
                            .font(Theme.Typography.small)
                            .foregroundColor(Theme.Colors.accent)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(Theme.Colors.accent)
                    }
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.surface)
                    .cornerRadius(Theme.CornerRadius.medium)
                }
            }
            
            if let docs = agent.technicalDetails.documentation {
                Link(destination: URL(string: docs)!) {
                    HStack {
                        Text("Documentation")
                            .font(Theme.Typography.small)
                            .foregroundColor(Theme.Colors.accent)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(Theme.Colors.accent)
                    }
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.surface)
                    .cornerRadius(Theme.CornerRadius.medium)
                }
            }
            
            if agent.technicalDetails.requiresAPIKey {
                InfoCard(
                    icon: "key.fill",
                    text: "This agent requires you to provide your own API key",
                    color: .orange
                )
            }
            
            if !agent.technicalDetails.environmentRequirements.isEmpty {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Requirements")
                        .font(Theme.Typography.small.weight(.bold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    ForEach(agent.technicalDetails.environmentRequirements, id: \.self) { req in
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(Theme.Colors.accent)
                            Text(req)
                                .font(Theme.Typography.tiny)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                    }
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.surface)
                .cornerRadius(Theme.CornerRadius.medium)
            }
        }
    }
    
    private var reviewsTab: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            if agent.reviews.isEmpty {
                VStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "star.fill")
                        .font(.largeTitle)
                        .foregroundColor(Theme.Colors.textSecondary.opacity(0.3))
                    Text("No reviews yet")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(Theme.Spacing.xl)
            } else {
                ForEach(agent.reviews) { review in
                    ReviewCard(review: review)
                }
            }
        }
    }
}

// MARK: - Helper Views

private struct AgentStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(Theme.Typography.body.weight(.bold))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text(label)
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

struct PerformanceRow: View {
    let label: String
    let value: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Spacer()
                
                Text(value)
                    .font(Theme.Typography.small.weight(.bold))
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Theme.Colors.border)
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 4)
                }
                .cornerRadius(2)
            }
            .frame(height: 4)
        }
    }
}

struct CapabilityCard: View {
    let capability: AgentCapability
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(capability.name)
                .font(Theme.Typography.body.weight(.bold))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text(capability.description)
                .font(Theme.Typography.small)
                .foregroundColor(Theme.Colors.textSecondary)
            
            if !capability.examples.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Examples:")
                        .font(Theme.Typography.tiny.weight(.bold))
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    ForEach(capability.examples, id: \.self) { example in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Theme.Colors.accent)
                                .frame(width: 4, height: 4)
                            Text(example)
                                .font(Theme.Typography.tiny)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                    }
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

struct TechnicalDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(Theme.Typography.small)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(Theme.Typography.small.weight(.semibold))
                .foregroundColor(Theme.Colors.textPrimary)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

struct InfoCard: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(text)
                .font(Theme.Typography.small)
                .foregroundColor(Theme.Colors.textPrimary)
        }
        .padding(Theme.Spacing.md)
        .background(color.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

struct ReviewCard: View {
    let review: AgentReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.reviewerName)
                        .font(Theme.Typography.small.weight(.bold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text(review.reviewerHandle)
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= review.rating ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            Text(review.comment)
                .font(Theme.Typography.small)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text(review.createdAt.formatted(date: .abbreviated, time: .omitted))
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

// MARK: - Tabs

enum AgentDetailTab: String, CaseIterable {
    case overview = "Overview"
    case capabilities = "Capabilities"
    case technical = "Technical"
    case reviews = "Reviews"
}

#Preview {
    AgentDetailView(agent: .sample)
}
