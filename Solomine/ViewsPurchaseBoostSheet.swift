//
//  ViewsPurchaseBoostSheet.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

/// Sheet for purchasing a boost package
struct PurchaseBoostSheet: View {
    let package: BoostPackage
    let onSuccess: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var adManager = AdvertisingManager.shared
    @State private var isProcessing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.xl) {
                        // Package Summary
                        packageSummary
                        
                        // What You Get
                        featuresSection
                        
                        // Pricing Breakdown
                        pricingBreakdown
                        
                        // Terms
                        termsSection
                        
                        // Purchase Button
                        purchaseButton
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .navigationTitle("Confirm Purchase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Package Summary
    
    private var packageSummary: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: package.campaignType.icon)
                .font(.system(size: 48))
                .foregroundColor(Theme.Colors.accent)
            
            Text(package.name)
                .font(Theme.Typography.h2)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text(package.description)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.medium)
    }
    
    // MARK: - Features Section
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("What You Get")
                .font(Theme.Typography.h3)
                .foregroundColor(Theme.Colors.textPrimary)
            
            VStack(spacing: Theme.Spacing.sm) {
                FeatureItem(
                    icon: "calendar",
                    text: "\(package.duration) days of boosted visibility"
                )
                
                FeatureItem(
                    icon: "eye.fill",
                    text: "\(package.estimatedImpressions)+ estimated impressions"
                )
                
                FeatureItem(
                    icon: "chart.bar.fill",
                    text: "Real-time analytics dashboard"
                )
                
                FeatureItem(
                    icon: "star.fill",
                    text: "Featured badge on your profile"
                )
                
                FeatureItem(
                    icon: "arrow.up.circle.fill",
                    text: "Top of \(package.placement.rawValue)"
                )
            }
        }
    }
    
    // MARK: - Pricing Breakdown
    
    private var pricingBreakdown: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Pricing")
                .font(Theme.Typography.h3)
                .foregroundColor(Theme.Colors.textPrimary)
            
            VStack(spacing: Theme.Spacing.sm) {
                PricingRow(label: "Package Price", value: package.price)
                
                Divider().background(Theme.Colors.border)
                
                HStack {
                    Text("Total")
                        .font(Theme.Typography.body.weight(.bold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", package.price))")
                        .font(Theme.Typography.h3)
                        .foregroundColor(Theme.Colors.accent)
                }
                
                Text("One-time payment • No subscription")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.CornerRadius.medium)
        }
    }
    
    // MARK: - Terms Section
    
    private var termsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack(spacing: 4) {
                Image(systemName: "info.circle")
                    .font(.caption)
                Text("Important")
                    .font(Theme.Typography.tiny.weight(.bold))
            }
            .foregroundColor(Theme.Colors.accent)
            
            Text("• Your boost starts immediately after payment\n• Campaigns are reviewed within 24 hours\n• Non-refundable once approved\n• You can pause or cancel anytime")
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.sm)
        .background(Theme.Colors.accent.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.small)
    }
    
    // MARK: - Purchase Button
    
    private var purchaseButton: some View {
        Button {
            purchaseBoost()
        } label: {
            if isProcessing {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Theme.Colors.background)
            } else {
                HStack {
                    Image(systemName: "apple.logo")
                    Text("Pay with Apple Pay")
                        .font(Theme.Typography.body.weight(.bold))
                }
                .foregroundColor(Theme.Colors.background)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.md)
        .background(isProcessing ? Theme.Colors.textSecondary : Theme.Colors.accent)
        .cornerRadius(Theme.CornerRadius.medium)
        .disabled(isProcessing)
    }
    
    // MARK: - Purchase Action
    
    private func purchaseBoost() {
        isProcessing = true
        
        Task {
            do {
                _ = try await adManager.purchaseBoostPackage(package)
                
                // Success
                isProcessing = false
                dismiss()
                onSuccess()
            } catch {
                isProcessing = false
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

// MARK: - Feature Item

struct FeatureItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(Theme.Colors.accent)
                .frame(width: 24)
            
            Text(text)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textPrimary)
        }
    }
}

// MARK: - Pricing Row

private struct PricingRow: View {
    let label: String
    let value: Double
    
    var body: some View {
        HStack {
            Text(label)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Spacer()
            
            Text("$\(String(format: "%.2f", value))")
                .font(Theme.Typography.body.weight(.semibold))
                .foregroundColor(Theme.Colors.textPrimary)
        }
    }
}

// MARK: - Campaign Detail View

struct CampaignDetailView: View {
    let campaign: AdCampaign
    
    @StateObject private var adManager = AdvertisingManager.shared
    @State private var showingPauseAlert = false
    @State private var showingCancelAlert = false
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Status Card
                    statusCard
                    
                    // Performance Metrics
                    metricsSection
                    
                    // Budget Progress
                    budgetSection
                    
                    // Actions
                    actionsSection
                }
                .padding(Theme.Spacing.md)
            }
        }
        .navigationTitle("Campaign Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Pause Campaign?", isPresented: $showingPauseAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Pause") {
                adManager.pauseCampaign(campaign.id)
            }
        } message: {
            Text("Your campaign will stop showing and budget won't be spent. You can resume anytime.")
        }
        .alert("Cancel Campaign?", isPresented: $showingCancelAlert) {
            Button("No", role: .cancel) { }
            Button("Yes, Cancel", role: .destructive) {
                Task {
                    try? await adManager.cancelCampaign(campaign.id)
                }
            }
        } message: {
            Text("Unused budget will be refunded. This action cannot be undone.")
        }
    }
    
    // MARK: - Status Card
    
    private var statusCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Image(systemName: campaign.campaignType.icon)
                    .font(.largeTitle)
                    .foregroundColor(Theme.Colors.accent)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(campaign.campaignType.rawValue)
                        .font(Theme.Typography.h3)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text(campaign.placement.rawValue)
                        .font(Theme.Typography.small)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                AdCampaignStatusBadge(status: campaign.status)
            }
            
            Divider().background(Theme.Colors.border)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Days Remaining")
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                    Text("\(campaign.daysRemaining)")
                        .font(Theme.Typography.h3)
                        .foregroundColor(Theme.Colors.textPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Ends")
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                    Text(campaign.endDate.formatted(date: .abbreviated, time: .omitted))
                        .font(Theme.Typography.small.weight(.semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.medium)
    }
    
    // MARK: - Metrics Section
    
    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Performance")
                .font(Theme.Typography.h3)
                .foregroundColor(Theme.Colors.textPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.sm) {
                MetricCard(
                    label: "Impressions",
                    value: "\(campaign.metrics.impressions)",
                    icon: "eye.fill",
                    color: .blue
                )
                
                MetricCard(
                    label: "Clicks",
                    value: "\(campaign.metrics.clicks)",
                    icon: "hand.tap.fill",
                    color: .green
                )
                
                MetricCard(
                    label: "CTR",
                    value: String(format: "%.1f%%", campaign.metrics.clickThroughRate * 100),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .orange
                )
                
                MetricCard(
                    label: "Conversions",
                    value: "\(campaign.metrics.conversions)",
                    icon: "checkmark.circle.fill",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Budget Section
    
    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Budget")
                .font(Theme.Typography.h3)
                .foregroundColor(Theme.Colors.textPrimary)
            
            VStack(spacing: Theme.Spacing.sm) {
                HStack {
                    Text("Spent")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", campaign.spent))")
                        .font(Theme.Typography.body.weight(.bold))
                        .foregroundColor(Theme.Colors.textPrimary)
                }
                
                HStack {
                    Text("Remaining")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", campaign.budgetRemaining))")
                        .font(Theme.Typography.body.weight(.bold))
                        .foregroundColor(Theme.Colors.accent)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Theme.Colors.border)
                            .frame(height: 8)
                        
                        Rectangle()
                            .fill(Theme.Colors.accent)
                            .frame(width: geometry.size.width * campaign.progress, height: 8)
                    }
                    .cornerRadius(4)
                }
                .frame(height: 8)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.CornerRadius.medium)
        }
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        VStack(spacing: Theme.Spacing.sm) {
            if campaign.status == .active {
                Button {
                    showingPauseAlert = true
                } label: {
                    Label("Pause Campaign", systemImage: "pause.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.orange)
            }
            
            if campaign.status == .paused {
                Button {
                    adManager.resumeCampaign(campaign.id)
                } label: {
                    Label("Resume Campaign", systemImage: "play.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
            
            if campaign.status == .active || campaign.status == .paused {
                Button(role: .destructive) {
                    showingCancelAlert = true
                } label: {
                    Label("Cancel Campaign", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

// MARK: - Metric Card

struct MetricCard: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(Theme.Typography.h3)
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

#Preview("Purchase Sheet") {
    PurchaseBoostSheet(package: BoostPackage.packages[0]) {
        print("Success")
    }
}

#Preview("Campaign Detail") {
    NavigationStack {
        CampaignDetailView(campaign: .sample)
    }
}
// MARK: - Ad Campaign Status Badge

struct AdCampaignStatusBadge: View {
    let status: AdCampaignStatus
    
    var body: some View {
        Text(status.rawValue.uppercased())
            .font(Theme.Typography.tiny)
            .foregroundColor(statusColor)
            .padding(.horizontal, Theme.Spacing.xs)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.2))
            .cornerRadius(Theme.CornerRadius.small)
    }
    
    private var statusColor: Color {
        switch status {
        case .pending: return Theme.Colors.accentSecondary
        case .active: return Theme.Colors.accent
        case .paused: return .orange
        case .completed: return .green
        case .cancelled: return .red
        case .rejected: return .red
        }
    }
}

