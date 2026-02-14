//
//  BuilderContractsView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI
internal import Combine

/// Builder's contracts management view with ability to create and send contracts for payment
struct BuilderContractsView: View {
    @StateObject private var viewModel = BuilderContractsViewModel()
    @State private var showingCreateContract = false
    @State private var selectedContract: Contract?
    @State private var showingContractDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with create button
            headerSection
            
            Divider().background(Theme.Colors.border)
            
            // Contracts list
            if viewModel.contracts.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    VStack(spacing: Theme.Spacing.md) {
                        // Filter tabs
                        filterSection
                        
                        // Contracts list
                        contractsList
                    }
                    .padding(Theme.Spacing.md)
                }
            }
        }
        .sheet(isPresented: $showingCreateContract) {
            BuilderCreateContractView(
                onContractCreated: { contract in
                    viewModel.addContract(contract)
                }
            )
        }
        .sheet(item: $selectedContract) { contract in
            ContractDetailsView(
                contract: contract,
                onStatusUpdate: { updatedContract in
                    viewModel.updateContract(updatedContract)
                }
            )
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("CONTRACTS")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Text("\(viewModel.filteredContracts.count) contract(s)")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
            
            Button(action: { showingCreateContract = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("CREATE CONTRACT")
                        .font(Theme.Typography.tiny.weight(.bold))
                }
                .foregroundColor(Theme.Colors.accent)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.backgroundElevated)
    }
    
    // MARK: - Filter Section
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(ContractFilterOption.allCases, id: \.self) { option in
                    ContractFilterChip(
                        title: option.title,
                        count: viewModel.countForFilter(option),
                        isSelected: viewModel.selectedFilter == option,
                        onTap: { viewModel.selectedFilter = option }
                    )
                }
            }
        }
    }
    
    // MARK: - Contracts List
    
    private var contractsList: some View {
        VStack(spacing: Theme.Spacing.sm) {
            ForEach(viewModel.filteredContracts) { contract in
                BuilderContractCard(
                    contract: contract,
                    onTap: {
                        selectedContract = contract
                    }
                )
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.textSecondary)
            
            Text("No Contracts Yet")
                .font(Theme.Typography.heading)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text("Create contracts to send to clients for payment.\nTrack project progress and get paid via Apple Pay.")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showingCreateContract = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("CREATE YOUR FIRST CONTRACT")
                        .font(Theme.Typography.caption.weight(.bold))
                }
                .foregroundColor(Theme.Colors.background)
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.md)
                .background(Theme.Colors.accent)
                .cornerRadius(Theme.CornerRadius.medium)
            }
            
            Spacer()
        }
        .padding(Theme.Spacing.xl)
    }
}

// MARK: - Contract Status Badge

private struct ContractStatusBadge: View {
    let status: ContractStatus
    
    var color: Color {
        switch status {
        case .draft:
            return .gray
        case .pendingSignature:
            return .orange
        case .active:
            return Theme.Colors.accent
        case .completed:
            return .green
        case .disputed:
            return .red
        case .cancelled:
            return .gray
        }
    }
    
    var body: some View {
        Text(status.rawValue.uppercased())
            .font(Theme.Typography.tiny)
            .foregroundColor(color)
            .fontWeight(.semibold)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(color.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .stroke(color, lineWidth: Theme.BorderWidth.thin)
            )
            .cornerRadius(Theme.CornerRadius.small)
    }
}

// MARK: - Contract Filter Chip (with count)

private struct ContractFilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(title)
                    .font(Theme.Typography.tiny)
                
                if count > 0 {
                    Text("\(count)")
                        .font(Theme.Typography.tiny.weight(.bold))
                }
            }
            .foregroundColor(isSelected ? Theme.Colors.background : Theme.Colors.textPrimary)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(isSelected ? Theme.Colors.accent : Theme.Colors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .stroke(isSelected ? Theme.Colors.accent : Theme.Colors.border, lineWidth: 1)
            )
            .cornerRadius(Theme.CornerRadius.small)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Builder Contract Card

struct BuilderContractCard: View {
    let contract: Contract
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                // Header with status
                HStack {
                    Text(contract.projectTitle)
                        .font(Theme.Typography.body.weight(.semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    ContractStatusBadge(status: contract.status)
                }
                
                // Amount and date
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 12))
                        Text("$\(String(format: "%.2f", contract.freelancerAmount))")
                            .font(Theme.Typography.caption.weight(.semibold))
                    }
                    .foregroundColor(Theme.Colors.accent)
                    
                    Spacer()
                    
                    Text(contract.createdAt.timeAgoString())
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                // Payment structure
                HStack(spacing: 4) {
                    Image(systemName: paymentIcon(for: contract.paymentStructure))
                        .font(.system(size: 10))
                    Text(contract.paymentStructure.displayName)
                        .font(Theme.Typography.tiny)
                }
                .foregroundColor(Theme.Colors.textSecondary)
                
                // Progress indicator for milestone contracts
                if case .milestones = contract.paymentStructure {
                    MilestoneProgressBar(milestones: contract.milestones)
                }
            }
            .padding(Theme.Spacing.md)
            .terminalCard()
        }
        .buttonStyle(.plain)
    }
    
    private func paymentIcon(for structure: PaymentStructure) -> String {
        switch structure {
        case .upfront:
            return "bolt.fill"
        case .milestones:
            return "chart.bar.fill"
        case .afterCompletion:
            return "checkmark.seal.fill"
        }
    }
}

// MARK: - Contract Filter Options

enum ContractFilterOption: CaseIterable {
    case all
    case pending
    case active
    case completed
    case draft
    
    var title: String {
        switch self {
        case .all: return "All"
        case .pending: return "Pending"
        case .active: return "Active"
        case .completed: return "Completed"
        case .draft: return "Drafts"
        }
    }
}

// MARK: - View Model

@MainActor
class BuilderContractsViewModel: ObservableObject {
    @Published var contracts: [Contract] = []
    @Published var selectedFilter: ContractFilterOption = .all
    
    var filteredContracts: [Contract] {
        switch selectedFilter {
        case .all:
            return contracts
        case .pending:
            return contracts.filter { $0.status == .pendingSignature }
        case .active:
            return contracts.filter { $0.status == .active }
        case .completed:
            return contracts.filter { $0.status == .completed }
        case .draft:
            return contracts.filter { $0.status == .draft }
        }
    }
    
    func countForFilter(_ filter: ContractFilterOption) -> Int {
        switch filter {
        case .all:
            return contracts.count
        case .pending:
            return contracts.filter { $0.status == .pendingSignature }.count
        case .active:
            return contracts.filter { $0.status == .active }.count
        case .completed:
            return contracts.filter { $0.status == .completed }.count
        case .draft:
            return contracts.filter { $0.status == .draft }.count
        }
    }
    
    func addContract(_ contract: Contract) {
        contracts.insert(contract, at: 0)
    }
    
    func updateContract(_ contract: Contract) {
        if let index = contracts.firstIndex(where: { $0.id == contract.id }) {
            contracts[index] = contract
        }
    }
}

// MARK: - Date Extension

extension Date {
    func timeAgoString() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear, .month], from: self, to: now)
        
        if let month = components.month, month > 0 {
            return "\(month)mo ago"
        } else if let week = components.weekOfYear, week > 0 {
            return "\(week)w ago"
        } else if let day = components.day, day > 0 {
            return "\(day)d ago"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)h ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)m ago"
        } else {
            return "just now"
        }
    }
}

#Preview {
    BuilderContractsView()
}
