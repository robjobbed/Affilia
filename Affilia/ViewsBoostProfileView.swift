//
//  ViewsBoostProfileView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

/// View for builders to purchase profile boosts and advertising
struct BoostProfileView: View {
    @StateObject private var adManager = AdvertisingManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPackage: BoostPackage?
    @State private var showingPurchaseSheet = false
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.xl) {
                        // Header
                        headerSection
                        
                        // Benefits
                        benefitsSection
                        
                        // Packages
                        packagesSection
                        
                        // Current Campaigns
                        if !adManager.myCampaigns.isEmpty {
                            currentCampaignsSection
                        }
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .navigationTitle("Boost Your Visibility")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
            }
            .sheet(item: $selectedPackage) { package in
                PurchaseBoostSheet(package: package) {
                    showingSuccess = true
                    selectedPackage = nil
                }
            }
            .alert("Success!", isPresented: $showingSuccess) {
                Button("OK") { }
            } message: {
                Text("Your boost is now active! Your profile will appear at the top of search results.")
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(Theme.Colors.accent)
            
            Text("Get More Visibility")
                .font(Theme.Typography.h1)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text("Boost your profile to appear at the top of search results and get more client inquiries")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Theme.Spacing.lg)
    }
    
    // MARK: - Benefits Section
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Why Boost?")
                .font(Theme.Typography.h3)
                .foregroundColor(Theme.Colors.textPrimary)
            
            VStack(spacing: Theme.Spacing.sm) {
                BoostBenefitRow(
                    icon: "magnifyingglass.circle.fill",
                    title: "Top of Search Results",
                    description: "Appear above regular listings"
                )
                
                BoostBenefitRow(
                    icon: "eye.fill",
                    title: "3-5x More Profile Views",
                    description: "Boosted profiles get significantly more visibility"
                )
                
                BoostBenefitRow(
                    icon: "star.fill",
                    title: "Featured Badge",
                    description: "Stand out with a 'Featured' badge on your profile"
                )
                
                BoostBenefitRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Analytics Dashboard",
                    description: "Track impressions, clicks, and conversions"
                )
            }
        }
    }
    
    // MARK: - Packages Section
    
    private var packagesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Choose Your Package")
                .font(Theme.Typography.h3)
                .foregroundColor(Theme.Colors.textPrimary)
            
            VStack(spacing: Theme.Spacing.md) {
                ForEach(BoostPackage.packages) { package in
                    BoostPackageCard(package: package) {
                        selectedPackage = package
                    }
                }
            }
        }
    }
    
    // MARK: - Current Campaigns Section
    
    private var currentCampaignsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Your Active Campaigns")
                .font(Theme.Typography.h3)
                .foregroundColor(Theme.Colors.textPrimary)
            
            VStack(spacing: Theme.Spacing.sm) {
                ForEach(adManager.myCampaigns.filter { $0.isActive }) { campaign in
                    NavigationLink {
                        CampaignDetailView(campaign: campaign)
                    } label: {
                        CampaignCard(campaign: campaign)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Benefit Row

private struct BoostBenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.accent.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Theme.Colors.accent)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.body.weight(.semibold))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(description)
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

// MARK: - Boost Package Card

struct BoostPackageCard: View {
    let package: BoostPackage
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(package.name)
                            .font(Theme.Typography.h3)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        if package.featured {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                Text("MOST POPULAR")
                                    .font(Theme.Typography.tiny.weight(.bold))
                            }
                            .foregroundColor(.yellow)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("$\(String(format: "%.2f", package.price))")
                            .font(Theme.Typography.h2)
                            .foregroundColor(Theme.Colors.accent)
                        
                        Text("\(package.duration) days")
                            .font(Theme.Typography.tiny)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                
                // Description
                Text(package.description)
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Divider().background(Theme.Colors.border)
                
                // Stats
                HStack(spacing: Theme.Spacing.lg) {
                    StatItem(
                        icon: "eye.fill",
                        label: "Est. Impressions",
                        value: "\(package.estimatedImpressions)+"
                    )
                    
                    StatItem(
                        icon: "calendar",
                        label: "Duration",
                        value: "\(package.duration)d"
                    )
                }
                
                // CTA
                HStack {
                    Text("Select Package")
                        .font(Theme.Typography.body.weight(.bold))
                        .foregroundColor(Theme.Colors.background)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(Theme.Colors.background)
                }
                .padding(Theme.Spacing.sm)
                .background(Theme.Colors.accent)
                .cornerRadius(Theme.CornerRadius.medium)
            }
            .padding(Theme.Spacing.md)
            .background(package.featured ? Theme.Colors.accent.opacity(0.1) : Theme.Colors.surface)
            .cornerRadius(Theme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(
                        package.featured ? Theme.Colors.accent : Theme.Colors.border,
                        lineWidth: package.featured ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Theme.Colors.accent)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
                Text(value)
                    .font(Theme.Typography.small.weight(.bold))
                    .foregroundColor(Theme.Colors.textPrimary)
            }
        }
    }
}

// MARK: - Campaign Card

struct CampaignCard: View {
    let campaign: AdCampaign
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: campaign.campaignType.icon)
                    .foregroundColor(Theme.Colors.accent)
                
                Text(campaign.campaignType.rawValue)
                    .font(Theme.Typography.body.weight(.semibold))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                AdStatusBadge(status: campaign.status)
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Budget")
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", campaign.spent)) / $\(String(format: "%.2f", campaign.budget))")
                        .font(Theme.Typography.tiny.weight(.bold))
                        .foregroundColor(Theme.Colors.accent)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Theme.Colors.border)
                            .frame(height: 4)
                        
                        Rectangle()
                            .fill(Theme.Colors.accent)
                            .frame(width: geometry.size.width * campaign.progress, height: 4)
                    }
                    .cornerRadius(2)
                }
                .frame(height: 4)
            }
            
            // Stats
            HStack(spacing: Theme.Spacing.md) {
                MetricView(label: "Views", value: "\(campaign.metrics.impressions)")
                MetricView(label: "Clicks", value: "\(campaign.metrics.clicks)")
                MetricView(label: "CTR", value: String(format: "%.1f%%", campaign.metrics.clickThroughRate * 100))
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

struct MetricView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(Theme.Typography.body.weight(.bold))
                .foregroundColor(Theme.Colors.textPrimary)
            Text(label)
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
}

private struct AdStatusBadge: View {
    let status: AdCampaignStatus
    
    var body: some View {
        Text(status.rawValue.uppercased())
            .font(Theme.Typography.tiny.weight(.bold))
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .cornerRadius(Theme.CornerRadius.small)
    }
    
    private var statusColor: Color {
        switch status {
        case .pending: return .orange
        case .active: return .green
        case .paused: return .yellow
        case .completed: return .blue
        case .cancelled: return .red
        case .rejected: return .red
        }
    }
}

#Preview {
    BoostProfileView()
}
