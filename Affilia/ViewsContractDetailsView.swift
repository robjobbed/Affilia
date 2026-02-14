//
//  ContractDetailsView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI
import PassKit
internal import Combine

// MARK: - Supporting Views

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(Theme.Colors.textSecondary)
                .frame(width: 20)
            
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(Theme.Typography.caption.weight(.semibold))
                .foregroundColor(Theme.Colors.textPrimary)
        }
    }
}

/// Detailed view of a contract with ability to request payment via Apple Pay
struct ContractDetailsView: View {
    let contract: Contract
    let onStatusUpdate: (Contract) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ContractDetailsViewModel
    @StateObject private var paymentManager = PaymentManager.shared
    
    init(contract: Contract, onStatusUpdate: @escaping (Contract) -> Void) {
        self.contract = contract
        self.onStatusUpdate = onStatusUpdate
        self._viewModel = StateObject(wrappedValue: ContractDetailsViewModel(contract: contract))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        // Status banner
                        statusBanner
                        
                        // Contract info
                        contractInfoSection
                        
                        Divider().background(Theme.Colors.border)
                        
                        // Payment breakdown
                        paymentBreakdownSection
                        
                        Divider().background(Theme.Colors.border)
                        
                        // Milestones
                        if !contract.milestones.isEmpty {
                            milestonesSection
                            Divider().background(Theme.Colors.border)
                        }
                        
                        // Payment actions
                        paymentActionsSection
                        
                        // Contract actions
                        contractActionsSection
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .navigationTitle("Contract Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: viewModel.shareContract) {
                            Label("Share Contract", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: viewModel.downloadPDF) {
                            Label("Download PDF", systemImage: "arrow.down.doc")
                        }
                        
                        Button(role: .destructive, action: viewModel.cancelContract) {
                            Label("Cancel Contract", systemImage: "xmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(Theme.Colors.accent)
                    }
                }
            }
            .alert("Payment Request", isPresented: $viewModel.showingPaymentConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Send Request") {
                    viewModel.sendPaymentRequest()
                }
            } message: {
                Text("Send payment request to client for \(viewModel.selectedMilestone?.title ?? "this milestone")?")
            }
            .alert("Contract Updated", isPresented: $viewModel.showingSuccessAlert) {
                Button("OK") {}
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
    
    // MARK: - Status Banner
    
    private var statusBanner: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: statusIcon)
                .font(.system(size: 20))
                .foregroundColor(statusColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(contract.status.rawValue.uppercased())
                    .font(Theme.Typography.body.weight(.bold))
                    .foregroundColor(statusColor)
                
                Text(statusDescription)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(Theme.Spacing.md)
        .background(statusColor.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.medium)
    }
    
    private var statusIcon: String {
        switch contract.status {
        case .draft: return "doc.text"
        case .pendingSignature: return "signature"
        case .active: return "checkmark.circle.fill"
        case .completed: return "checkmark.seal.fill"
        case .disputed: return "exclamationmark.triangle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch contract.status {
        case .draft: return Theme.Colors.textSecondary
        case .pendingSignature: return .orange
        case .active: return Theme.Colors.accent
        case .completed: return .green
        case .disputed: return .red
        case .cancelled: return .red
        }
    }
    
    private var statusDescription: String {
        switch contract.status {
        case .draft:
            return "Contract is being drafted"
        case .pendingSignature:
            return "Waiting for client to accept and pay"
        case .active:
            return "Contract is active, work in progress"
        case .completed:
            return "All milestones completed and paid"
        case .disputed:
            return "Contract is under dispute"
        case .cancelled:
            return "Contract has been cancelled"
        }
    }
    
    // MARK: - Contract Info
    
    private var contractInfoSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(contract.projectTitle)
                .font(Theme.Typography.headingLarge)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text(contract.projectDescription)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
            
            // Meta info
            VStack(spacing: Theme.Spacing.xs) {
                InfoRow(icon: "calendar", label: "Created", value: contract.createdAt.formatted(date: .abbreviated, time: .omitted))
                InfoRow(icon: "chart.bar", label: "Payment Type", value: contract.paymentStructure.displayName)
            }
        }
    }
    
    // MARK: - Payment Breakdown
    
    private var paymentBreakdownSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("PAYMENT BREAKDOWN")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            VStack(spacing: Theme.Spacing.xs) {
                BreakdownRow(label: "Contract Value", amount: contract.totalAmount)
                BreakdownRow(label: "Platform Fee (5%)", amount: contract.platformFee, color: Theme.Colors.textSecondary)
                BreakdownRow(label: "You Receive", amount: contract.freelancerAmount, color: Theme.Colors.accent)
                
                Divider().background(Theme.Colors.border)
                
                BreakdownRow(
                    label: "Client Pays",
                    amount: contract.hirerTotalCost,
                    color: Theme.Colors.textPrimary,
                    isTotal: true
                )
            }
            .padding(Theme.Spacing.md)
            .terminalCard()
        }
    }
    
    // MARK: - Milestones Section
    
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Text("MILESTONES")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Spacer()
                
                let completed = contract.milestones.filter { $0.status == .paid }.count
                Text("\(completed) / \(contract.milestones.count) PAID")
                    .font(Theme.Typography.tiny.weight(.bold))
                    .foregroundColor(Theme.Colors.accent)
            }
            
            ForEach(contract.milestones.sorted(by: { $0.order < $1.order })) { milestone in
                MilestoneCard(
                    milestone: milestone,
                    onRequestPayment: {
                        viewModel.selectedMilestone = milestone
                        viewModel.showingPaymentConfirmation = true
                    }
                )
            }
        }
    }
    
    // MARK: - Payment Actions
    
    private var paymentActionsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("PAYMENT ACTIONS")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            if contract.status == .pendingSignature {
                ActionButton(
                    icon: "paperplane.fill",
                    title: "Send Payment Request",
                    subtitle: "Request client to pay via Apple Pay",
                    color: Theme.Colors.accent,
                    action: {
                        viewModel.sendPaymentRequest()
                    }
                )
            } else if contract.status == .active {
                ActionButton(
                    icon: "dollarsign.circle.fill",
                    title: "Request Milestone Payment",
                    subtitle: "Send payment link for next milestone",
                    color: Theme.Colors.accent,
                    action: {
                        if let nextMilestone = contract.milestones.first(where: { $0.status == .pending || $0.status == .completed }) {
                            viewModel.selectedMilestone = nextMilestone
                            viewModel.showingPaymentConfirmation = true
                        }
                    }
                )
            }
            
            // Show payment link
            if contract.status == .pendingSignature || contract.status == .active {
                CopyableLinkCard(
                    title: "Payment Link",
                    link: viewModel.generatePaymentLink(),
                    icon: "link.circle.fill"
                )
            }
        }
    }
    
    // MARK: - Contract Actions
    
    private var contractActionsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("CONTRACT ACTIONS")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            if contract.status == .active {
                ActionButton(
                    icon: "checkmark.circle.fill",
                    title: "Mark as Completed",
                    subtitle: "Mark all work as complete",
                    color: .green,
                    action: viewModel.markContractComplete
                )
            }
            
            if contract.status != .cancelled && contract.status != .completed {
                ActionButton(
                    icon: "exclamationmark.triangle.fill",
                    title: "Report Issue",
                    subtitle: "File a dispute for this contract",
                    color: .orange,
                    action: viewModel.reportIssue
                )
            }
        }
    }
}

// MARK: - Supporting Views

struct MilestoneCard: View {
    let milestone: Milestone
    let onRequestPayment: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(milestone.title)
                        .font(Theme.Typography.body.weight(.semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text(milestone.description)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.2f", milestone.freelancerAmount))")
                        .font(Theme.Typography.body.weight(.bold))
                        .foregroundColor(Theme.Colors.accent)
                    
                    MilestoneStatusBadge(status: milestone.status)
                }
            }
            
            // Request payment button
            if milestone.status == .completed || milestone.status == .pending {
                Button(action: onRequestPayment) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("REQUEST PAYMENT")
                            .font(Theme.Typography.tiny.weight(.bold))
                    }
                    .foregroundColor(Theme.Colors.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(Theme.Colors.accent)
                    .cornerRadius(Theme.CornerRadius.small)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .terminalCard()
    }
}

struct MilestoneStatusBadge: View {
    let status: MilestoneStatus
    
    var body: some View {
        Text(status.rawValue.uppercased())
            .font(Theme.Typography.tiny.weight(.bold))
            .foregroundColor(statusColor)
            .padding(.horizontal, Theme.Spacing.xs)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.15))
            .cornerRadius(Theme.CornerRadius.small)
    }
    
    private var statusColor: Color {
        switch status {
        case .pending: return Theme.Colors.textSecondary
        case .inProgress: return .orange
        case .completed: return Theme.Colors.accent
        case .paid: return .green
        case .disputed: return .red
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Theme.Typography.body.weight(.semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text(subtitle)
                        .font(Theme.Typography.caption)
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

struct CopyableLinkCard: View {
    let title: String
    let link: String
    let icon: String
    @State private var showingCopiedConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Theme.Colors.accent)
                Text(title)
                    .font(Theme.Typography.caption.weight(.semibold))
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            HStack(spacing: Theme.Spacing.sm) {
                Text(link)
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer()
                
                Button(action: {
                    UIPasteboard.general.string = link
                    showingCopiedConfirmation = true
                    
                    // Haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showingCopiedConfirmation = false
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: showingCopiedConfirmation ? "checkmark" : "doc.on.doc")
                        Text(showingCopiedConfirmation ? "COPIED" : "COPY")
                            .font(Theme.Typography.tiny.weight(.bold))
                    }
                    .foregroundColor(showingCopiedConfirmation ? .green : Theme.Colors.accent)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .terminalCard()
    }
}

// MARK: - View Model

@MainActor
class ContractDetailsViewModel: ObservableObject {
    @Published var contract: Contract
    @Published var showingPaymentConfirmation = false
    @Published var showingSuccessAlert = false
    @Published var alertMessage = ""
    @Published var selectedMilestone: Milestone?
    
    init(contract: Contract) {
        self.contract = contract
    }
    
    func generatePaymentLink() -> String {
        // In production, this would be a real deep link that opens the app to payment screen
        return "https://affilia.app/pay/\(contract.id.uuidString)"
    }
    
    func sendPaymentRequest() {
        // In production, this would:
        // 1. Generate a secure payment link
        // 2. Send push notification to client
        // 3. Send email with payment link
        // 4. Log the request in your backend
        
        print("📤 Sending payment request for contract: \(contract.projectTitle)")
        print("   Amount: $\(contract.hirerTotalCost)")
        print("   Payment link: \(generatePaymentLink())")
        
        alertMessage = "Payment request sent to client!"
        showingSuccessAlert = true
    }
    
    func markContractComplete() {
        contract.status = .completed
        alertMessage = "Contract marked as complete!"
        showingSuccessAlert = true
    }
    
    func reportIssue() {
        contract.status = .disputed
        alertMessage = "Dispute filed. Our team will review shortly."
        showingSuccessAlert = true
    }
    
    func shareContract() {
        // Share sheet with contract details
        print("📱 Sharing contract...")
    }
    
    func downloadPDF() {
        // Generate and download PDF
        print("📄 Downloading PDF...")
    }
    
    func cancelContract() {
        contract.status = .cancelled
        alertMessage = "Contract has been cancelled."
        showingSuccessAlert = true
    }
}

#Preview {
    ContractDetailsView(
        contract: Contract(
            hirerId: UUID(),
            freelancerId: UUID(),
            projectTitle: "iOS App Development",
            projectDescription: "Build a SwiftUI app with custom animations",
            totalAmount: 50000,
            paymentStructure: .milestones([
                MilestonePercentage(percentage: 0.5, description: "50% upfront"),
                MilestonePercentage(percentage: 0.5, description: "50% on completion")
            ]),
            milestones: [
                Milestone(
                    contractId: UUID(),
                    title: "Milestone 1",
                    description: "Initial setup and design",
                    amount: 25000,
                    percentage: 0.5,
                    order: 1,
                    status: .paid
                ),
                Milestone(
                    contractId: UUID(),
                    title: "Milestone 2",
                    description: "Final delivery",
                    amount: 25000,
                    percentage: 0.5,
                    order: 2,
                    status: .pending
                )
            ],
            status: .active
        ),
        onStatusUpdate: { _ in }
    )
}
