//
//  FreelancerDashboardView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct FreelancerDashboardView: View {
    @State private var selectedTab: FreelancerDashboardTab = .overview
    @State private var contracts: [Contract] = []
    @State private var earnings: FreelancerEarnings = .sample
    @State private var showingAnalytics = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Tab selector
                    tabSelector
                    
                    Divider().background(Theme.Colors.border)
                    
                    // Content
                    ScrollView {
                        VStack(spacing: Theme.Spacing.lg) {
                            switch selectedTab {
                            case .overview:
                                overviewSection
                            case .activeContracts:
                                BuilderContractsView()
                            case .earnings:
                                earningsSection
                            case .pricing:
                                pricingSection
                            }
                        }
                        .padding(Theme.Spacing.md)
                    }
                }
            }
            .navigationTitle("Affiliate Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showingAnalytics) {
                AnalyticsView()
            }
        }
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(FreelancerDashboardTab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: .regular, design: .monospaced))
                        Text(tab.title)
                            .font(Theme.Typography.tiny)
                    }
                    .foregroundColor(selectedTab == tab ? Theme.Colors.accent : Theme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(selectedTab == tab ? Theme.Colors.accent.opacity(0.1) : Color.clear)
                }
            }
        }
        .background(Theme.Colors.backgroundElevated)
    }
    
    // MARK: - Overview Section
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            // Stats cards
            statsGrid
            
            // Quick actions
            quickActionsSection
            
            // Recent activity
            recentActivitySection
        }
    }
    
    private var statsGrid: some View {
        VStack(spacing: Theme.Spacing.sm) {
            HStack(spacing: Theme.Spacing.sm) {
                StatCard(
                    title: "ACTIVE CONTRACTS",
                    value: "\(contracts.filter { $0.status == .active }.count)",
                    icon: "doc.text.fill",
                    color: Theme.Colors.accent
                )
                
                StatCard(
                    title: "THIS MONTH",
                    value: "$\(String(format: "%.0f", earnings.thisMonth))",
                    icon: "dollarsign.circle.fill",
                    color: Theme.Colors.accentSecondary
                )
            }
            
            HStack(spacing: Theme.Spacing.sm) {
                StatCard(
                    title: "TOTAL EARNED",
                    value: "$\(String(format: "%.0f", earnings.totalEarned))",
                    icon: "chart.line.uptrend.xyaxis",
                    color: Theme.Colors.accent
                )
                
                StatCard(
                    title: "PENDING",
                    value: "$\(String(format: "%.0f", earnings.pending))",
                    icon: "clock.fill",
                    color: Theme.Colors.textSecondary
                )
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("QUICK ACTIONS")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            VStack(spacing: Theme.Spacing.sm) {
                QuickActionButton(
                    icon: "dollarsign.circle",
                    title: "Update Channel Fit",
                    description: "Set channel preferences and payout targets",
                    action: { selectedTab = .pricing }
                )
                
                QuickActionButton(
                    icon: "person.fill.checkmark",
                    title: "Edit Profile",
                    description: "Update skills and portfolio",
                    action: {}
                )
                
                QuickActionButton(
                    icon: "chart.bar",
                    title: "View Analytics",
                    description: "Track your performance",
                    action: { showingAnalytics = true }
                )
            }
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("RECENT ACTIVITY")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            VStack(spacing: Theme.Spacing.xs) {
                FreelancerActivityItem(
                    icon: "checkmark.circle.fill",
                    text: "Milestone completed for iOS App Project",
                    time: "2 hours ago",
                    color: Theme.Colors.accent
                )
                
                FreelancerActivityItem(
                    icon: "dollarsign.circle.fill",
                    text: "Payment received: $12,500",
                    time: "1 day ago",
                    color: Theme.Colors.accentSecondary
                )
                
                FreelancerActivityItem(
                    icon: "doc.text.fill",
                    text: "New contract signed: NeonCart Creator Program",
                    time: "3 days ago",
                    color: Theme.Colors.accent
                )
            }
        }
    }
    
    // MARK: - Active Contracts Section
    
    private var activeContractsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Filter/sort options
            HStack {
                Text("\(contracts.count) CONTRACT(S)")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Spacer()
                
                Menu {
                    Button("All Contracts") {}
                    Button("Active Only") {}
                    Button("Pending Signature") {}
                    Button("Completed") {}
                } label: {
                    HStack(spacing: 4) {
                        Text("Filter")
                            .font(Theme.Typography.caption)
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
            }
            
            // Contracts list
            if contracts.isEmpty {
                emptyContractsState
            } else {
                ForEach(contracts) { contract in
                    ContractCard(contract: contract)
                }
            }
        }
    }
    
    private var emptyContractsState: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(Theme.Colors.textSecondary)
            
            Text("No contracts yet")
                .font(Theme.Typography.title)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text("Contracts will appear here once companies publish them")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.xxl)
    }
    
    // MARK: - Earnings Section
    
    private var earningsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            // Summary cards
            VStack(spacing: Theme.Spacing.sm) {
                EarningsCard(
                    title: "TOTAL LIFETIME EARNINGS",
                    amount: earnings.totalEarned,
                    subtitle: "After estimated platform fee",
                    isPrimary: true
                )
                
                HStack(spacing: Theme.Spacing.sm) {
                    EarningsCard(
                        title: "THIS MONTH",
                        amount: earnings.thisMonth,
                        subtitle: "\(earnings.paymentsThisMonth) payment(s)"
                    )
                    
                    EarningsCard(
                        title: "LAST MONTH",
                        amount: earnings.lastMonth,
                        subtitle: "\(earnings.paymentsLastMonth) payment(s)"
                    )
                }
                
                EarningsCard(
                    title: "PENDING PAYMENTS",
                    amount: earnings.pending,
                    subtitle: "From incomplete milestones",
                    color: Theme.Colors.accentSecondary
                )
            }
            
            // Payment history
            paymentHistorySection
        }
    }
    
    private var paymentHistorySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("PAYMENT HISTORY")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            VStack(spacing: Theme.Spacing.xs) {
                ForEach(earnings.recentPayments) { payment in
                    PaymentHistoryRow(payment: payment)
                }
            }
        }
    }
    
    // MARK: - Pricing Section
    
    private var pricingSection: some View {
        FreelancerPricingEditor()
    }
}

// MARK: - Freelancer Pricing Editor

struct FreelancerPricingEditor: View {
    @State private var hourlyRate = ""
    @State private var projectMinimum = ""
    @State private var availability: AvailabilityStatus = .openToWork
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            // Header
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("SET YOUR RATES")
                    .font(Theme.Typography.title)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("Configure your preferred commission floor and availability")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Divider().background(Theme.Colors.border)
            
            // Hourly rate
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(Theme.Colors.accent)
                    Text("MIN CPA TARGET")
                        .font(Theme.Typography.caption.weight(.bold))
                        .foregroundColor(Theme.Colors.accent)
                }
                
                Text("Target minimum payout per approved conversion")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                HStack {
                    Text("$")
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.Colors.accent)
                    TextField("35", text: $hourlyRate)
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .keyboardType(.decimalPad)
                    Text("/ conversion")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .padding(Theme.Spacing.md)
                .terminalCard()
                
                // Rate suggestion
                if let rate = Double(hourlyRate), rate > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("After estimated platform fee:")
                            .font(Theme.Typography.tiny)
                            .foregroundColor(Theme.Colors.textSecondary)
                        Text("You earn: $\(String(format: "%.2f", rate * 0.95))/conversion")
                            .font(Theme.Typography.caption.weight(.bold))
                            .foregroundColor(Theme.Colors.accent)
                    }
                    .padding(Theme.Spacing.sm)
                    .background(Theme.Colors.accent.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.medium)
                }
            }
            
            Divider().background(Theme.Colors.border)
            
            // Project-based minimum
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(Theme.Colors.accentSecondary)
                    Text("CAMPAIGN MINIMUM")
                        .font(Theme.Typography.caption.weight(.bold))
                        .foregroundColor(Theme.Colors.accentSecondary)
                }
                
                Text("Minimum monthly payout pool you'll accept")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                HStack {
                    Text("$")
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.Colors.accentSecondary)
                    TextField("3000", text: $projectMinimum)
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .keyboardType(.decimalPad)
                    Text("pool")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .padding(Theme.Spacing.md)
                .terminalCard()
                
                if let minimum = Double(projectMinimum), minimum > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("After estimated platform fee:")
                            .font(Theme.Typography.tiny)
                            .foregroundColor(Theme.Colors.textSecondary)
                        Text("You earn: $\(String(format: "%.2f", minimum * 0.95))")
                            .font(Theme.Typography.caption.weight(.bold))
                            .foregroundColor(Theme.Colors.accentSecondary)
                    }
                    .padding(Theme.Spacing.sm)
                    .background(Theme.Colors.accentSecondary.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.medium)
                }
            }
            
            Divider().background(Theme.Colors.border)
            
            // Availability
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("AVAILABILITY STATUS")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                ForEach(AvailabilityStatus.allCases, id: \.self) { status in
                    AvailabilityCard(
                        status: status,
                        isSelected: availability == status,
                        onSelect: { availability = status }
                    )
                }
            }
            
            // Save button
            Button(action: { showingSaveConfirmation = true }) {
                Text("SAVE PRICING SETTINGS")
                    .font(Theme.Typography.body.weight(.bold))
                    .foregroundColor(Theme.Colors.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.md)
                    .background(Theme.Colors.accent)
                    .cornerRadius(Theme.CornerRadius.medium)
            }
        }
        .alert("Preferences Updated", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your affiliate preferences are now visible to companies.")
        }
    }
}

// MARK: - Supporting Views

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                Text(title)
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Text(value)
                .font(Theme.Typography.heading)
                .foregroundColor(Theme.Colors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.md)
        .terminalCard()
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Theme.Colors.accent)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textPrimary)
                    Text(description)
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(Theme.Spacing.md)
            .terminalCard()
        }
        .buttonStyle(.plain)
    }
}

struct FreelancerActivityItem: View {
    let icon: String
    let text: String
    let time: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textPrimary)
                Text(time)
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(Theme.Spacing.sm)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.small)
    }
}

struct ContractCard: View {
    let contract: Contract
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            // Header
            HStack {
                Text(contract.projectTitle)
                    .font(Theme.Typography.title)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                StatusBadge(status: contract.status)
            }
            
            // Amount and milestones
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CONTRACT VALUE")
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                    Text("$\(String(format: "%.2f", contract.totalAmount))")
                        .font(Theme.Typography.body.weight(.bold))
                        .foregroundColor(Theme.Colors.accent)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("YOU RECEIVE")
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                    Text("$\(String(format: "%.2f", contract.freelancerAmount))")
                        .font(Theme.Typography.body.weight(.bold))
                        .foregroundColor(Theme.Colors.accent)
                }
            }
            
            // Milestones progress
            if !contract.milestones.isEmpty {
                MilestoneProgressBar(milestones: contract.milestones)
            }
            
            // Action button
            Button(action: {}) {
                HStack {
                    Text("VIEW CONTRACT")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.accent)
                .padding(.vertical, Theme.Spacing.sm)
            }
        }
        .padding(Theme.Spacing.md)
        .terminalCard()
    }
}

struct StatusBadge: View {
    let status: ContractStatus
    
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
        case .draft: return Theme.Colors.textSecondary
        case .pendingSignature: return Theme.Colors.accentSecondary
        case .active: return Theme.Colors.accent
        case .completed: return .green
        case .disputed: return .red
        case .cancelled: return .red
        }
    }
}

struct MilestoneProgressBar: View {
    let milestones: [Milestone]
    
    var completedCount: Int {
        milestones.filter { $0.status == .paid }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("MILESTONES")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
                Spacer()
                Text("\(completedCount)/\(milestones.count) COMPLETED")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.accent)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Theme.Colors.border)
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Theme.Colors.accent)
                        .frame(width: geometry.size.width * CGFloat(completedCount) / CGFloat(milestones.count), height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

struct EarningsCard: View {
    let title: String
    let amount: Double
    let subtitle: String
    var isPrimary: Bool = false
    var color: Color = Theme.Colors.accent
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(title)
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Text("$\(String(format: "%.2f", amount))")
                .font(isPrimary ? Theme.Typography.headingLarge : Theme.Typography.heading)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.md)
        .background(isPrimary ? color.opacity(0.1) : Theme.Colors.surface)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .stroke(isPrimary ? color : Theme.Colors.border, lineWidth: isPrimary ? 2 : 1)
        )
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

struct PaymentHistoryRow: View {
    let payment: PaymentHistoryItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(payment.projectTitle)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textPrimary)
                Text(payment.date)
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
            
            Text("+$\(String(format: "%.2f", payment.amount))")
                .font(Theme.Typography.body.weight(.bold))
                .foregroundColor(Theme.Colors.accent)
        }
        .padding(Theme.Spacing.sm)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.small)
    }
}

struct AvailabilityCard: View {
    let status: AvailabilityStatus
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Theme.Colors.accent : Theme.Colors.textSecondary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(status.rawValue)
                        .font(Theme.Typography.body.weight(.semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    Text(status.description)
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
            }
            .padding(Theme.Spacing.sm)
            .background(isSelected ? Theme.Colors.accent.opacity(0.1) : Theme.Colors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(isSelected ? Theme.Colors.accent : Theme.Colors.border, lineWidth: isSelected ? 2 : 1)
            )
            .cornerRadius(Theme.CornerRadius.medium)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Supporting Models

enum FreelancerDashboardTab: CaseIterable {
    case overview
    case activeContracts
    case earnings
    case pricing
    
    var title: String {
        switch self {
        case .overview: return "Overview"
        case .activeContracts: return "Contracts"
        case .earnings: return "Earnings"
        case .pricing: return "Pricing"
        }
    }
    
    var icon: String {
        switch self {
        case .overview: return "square.grid.2x2"
        case .activeContracts: return "doc.text"
        case .earnings: return "dollarsign.circle"
        case .pricing: return "slider.horizontal.3"
        }
    }
}

struct FreelancerEarnings {
    let totalEarned: Double
    let thisMonth: Double
    let lastMonth: Double
    let pending: Double
    let paymentsThisMonth: Int
    let paymentsLastMonth: Int
    let recentPayments: [PaymentHistoryItem]
    
    static let sample = FreelancerEarnings(
        totalEarned: 127500,
        thisMonth: 23750,
        lastMonth: 18500,
        pending: 12500,
        paymentsThisMonth: 3,
        paymentsLastMonth: 2,
        recentPayments: [
            PaymentHistoryItem(projectTitle: "iOS App - Milestone 2", amount: 12500, date: "Feb 1, 2026"),
            PaymentHistoryItem(projectTitle: "Website Redesign - Final", amount: 8750, date: "Jan 28, 2026"),
            PaymentHistoryItem(projectTitle: "API Integration", amount: 2500, date: "Jan 25, 2026")
        ]
    )
}

struct PaymentHistoryItem: Identifiable {
    let id = UUID()
    let projectTitle: String
    let amount: Double
    let date: String
}

extension AvailabilityStatus {
    var description: String {
        switch self {
        case .openToWork:
            return "Available for new projects"
        case .booked:
            return "Not taking new work"
        case .selective:
            return "Only certain projects"
        }
    }
}

#Preview {
    FreelancerDashboardView()
}
