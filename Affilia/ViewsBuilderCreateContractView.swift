//
//  BuilderCreateContractView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI
internal import Combine

/// View for builders to create contracts to send to clients
struct BuilderCreateContractView: View {
    let onContractCreated: (Contract) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BuilderCreateContractViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        // Info banner
                        infoBanner
                        
                        // Client selection
                        clientSection
                        
                        Divider().background(Theme.Colors.border)
                        
                        // Project details
                        projectDetailsSection
                        
                        Divider().background(Theme.Colors.border)
                        
                        // Deliverables
                        deliverablesSection
                        
                        Divider().background(Theme.Colors.border)
                        
                        // Payment structure
                        paymentStructureSection
                        
                        // Payment breakdown
                        if viewModel.totalAmount > 0 {
                            paymentBreakdownCard
                        }
                        
                        // Terms and conditions
                        termsSection
                        
                        // Create button
                        createContractButton
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .navigationTitle("Create Contract")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .sheet(isPresented: $viewModel.showingClientPicker) {
                ClientPickerView(selectedClient: $viewModel.selectedClient)
            }
        }
    }
    
    // MARK: - Info Banner
    
    private var infoBanner: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(Theme.Colors.accent)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Create a contract to send to your client")
                    .font(Theme.Typography.caption.weight(.semibold))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("They'll pay via Apple Pay. You receive 95% after platform fee.")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.accent.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.medium)
    }
    
    // MARK: - Client Section
    
    private var clientSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("CLIENT")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            if let client = viewModel.selectedClient {
                HStack(spacing: Theme.Spacing.sm) {
                    AvatarView(displayName: client.displayName, size: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(client.displayName)
                            .font(Theme.Typography.body.weight(.semibold))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text(client.email)
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button("Change") {
                        viewModel.showingClientPicker = true
                    }
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.accent)
                }
                .padding(Theme.Spacing.md)
                .terminalCard()
            } else {
                Button(action: { viewModel.showingClientPicker = true }) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                        Text("SELECT CLIENT")
                            .font(Theme.Typography.caption.weight(.semibold))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(Theme.Colors.accent)
                    .padding(Theme.Spacing.md)
                    .terminalCard()
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Project Details
    
    private var projectDetailsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("PROJECT DETAILS")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            // Title
            FormField(
                label: "Project Title",
                placeholder: "e.g., iOS App Development",
                text: $viewModel.projectTitle
            )
            
            // Description
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Description")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                TextEditor(text: $viewModel.projectDescription)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .frame(height: 120)
                    .scrollContentBackground(.hidden)
                    .padding(Theme.Spacing.sm)
                    .terminalCard()
            }
            
            // Timeline
            HStack(spacing: Theme.Spacing.md) {
                FormField(
                    label: "Start Date",
                    placeholder: "MM/DD/YYYY",
                    text: $viewModel.startDate
                )
                
                FormField(
                    label: "End Date",
                    placeholder: "MM/DD/YYYY",
                    text: $viewModel.endDate
                )
            }
        }
    }
    
    // MARK: - Deliverables
    
    private var deliverablesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Text("DELIVERABLES")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Spacer()
                
                Button(action: viewModel.addDeliverable) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Theme.Colors.accent)
                }
            }
            
            ForEach(viewModel.deliverables.indices, id: \.self) { index in
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "checkmark.square")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.Colors.accent)
                    
                    TextField("Deliverable description", text: $viewModel.deliverables[index])
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(Theme.Spacing.sm)
                        .terminalCard()
                    
                    if viewModel.deliverables.count > 1 {
                        Button(action: { viewModel.removeDeliverable(at: index) }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Payment Structure
    
    private var paymentStructureSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("PAYMENT")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            // Total amount
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Total Contract Value")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                HStack {
                    Text("$")
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.Colors.accent)
                    TextField("50000", value: $viewModel.totalAmount, format: .number)
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .keyboardType(.decimalPad)
                }
                .padding(Theme.Spacing.sm)
                .terminalCard()
            }
            
            // Payment structure options
            Text("Payment Structure")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .padding(.top, Theme.Spacing.sm)
            
            ForEach(PaymentStructureOption.allCases, id: \.self) { option in
                PaymentStructureCard(
                    option: option,
                    isSelected: viewModel.selectedPaymentStructure == option,
                    onSelect: { viewModel.selectedPaymentStructure = option }
                )
            }
            
            // Custom milestones editor
            if viewModel.selectedPaymentStructure == .milestones {
                customMilestonesEditor
            }
        }
    }
    
    private var customMilestonesEditor: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Text("CONFIGURE MILESTONES")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Spacer()
                
                Text("\(viewModel.customMilestones.totalPercentage)% / 100%")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(viewModel.customMilestones.totalPercentage == 100 ? Theme.Colors.accent : .red)
                
                Button(action: viewModel.addMilestone) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(Theme.Colors.accent)
                }
            }
            
            ForEach(viewModel.customMilestones.indices, id: \.self) { index in
                HStack(spacing: Theme.Spacing.sm) {
                    TextField("%", value: $viewModel.customMilestones[index].percentage, format: .number)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .keyboardType(.numberPad)
                        .frame(width: 50)
                        .padding(Theme.Spacing.xs)
                        .terminalCard()
                    
                    Text("%")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    TextField("Description", text: $viewModel.customMilestones[index].description)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(Theme.Spacing.xs)
                        .terminalCard()
                    
                    if viewModel.customMilestones.count > 1 {
                        Button(action: { viewModel.removeMilestone(at: index) }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            if viewModel.customMilestones.totalPercentage != 100 {
                Text("⚠️ Milestones must total 100%")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(.red)
            }
        }
        .padding(Theme.Spacing.sm)
        .terminalCard()
    }
    
    // MARK: - Payment Breakdown
    
    private var paymentBreakdownCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(Theme.Colors.accent)
                Text("PAYMENT BREAKDOWN")
                    .font(Theme.Typography.caption.weight(.bold))
                    .foregroundColor(Theme.Colors.accent)
            }
            
            Divider().background(Theme.Colors.border)
            
            let breakdown = viewModel.calculateBreakdown()
            
            BreakdownRow(label: "Contract Value", amount: breakdown.contractValue)
            BreakdownRow(label: "Platform Fee (5%)", amount: breakdown.platformFee, color: Theme.Colors.textSecondary)
            BreakdownRow(label: "You Receive", amount: breakdown.freelancerReceives, color: Theme.Colors.accent)
            
            Divider().background(Theme.Colors.border)
            
            BreakdownRow(
                label: "Client Pays",
                amount: breakdown.hirerPays,
                color: Theme.Colors.textPrimary,
                isTotal: true
            )
            
            if breakdown.hirerPaysAdditionalFee {
                Text("💡 Client pays extra 5% fee for 'Pay After Completion' option")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.accentSecondary)
                    .padding(.top, Theme.Spacing.xs)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .stroke(Theme.Colors.accent.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(Theme.CornerRadius.medium)
    }
    
    // MARK: - Terms
    
    private var termsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("ADDITIONAL TERMS")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            TextEditor(text: $viewModel.additionalTerms)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textPrimary)
                .frame(height: 80)
                .scrollContentBackground(.hidden)
                .padding(Theme.Spacing.sm)
                .terminalCard()
            
            Text("Optional: Add any additional terms or conditions")
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
    
    // MARK: - Create Button
    
    private var createContractButton: some View {
        Button(action: createContract) {
            Text("CREATE & SEND CONTRACT")
                .font(Theme.Typography.caption.weight(.bold))
                .foregroundColor(Theme.Colors.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.md)
                .background(viewModel.isValid ? Theme.Colors.accent : Theme.Colors.textSecondary)
                .cornerRadius(Theme.CornerRadius.medium)
        }
        .disabled(!viewModel.isValid)
    }
    
    // MARK: - Actions
    
    private func createContract() {
        let contract = viewModel.createContract()
        onContractCreated(contract)
        dismiss()
    }
}

// MARK: - Form Field Component

private struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            TextField(placeholder, text: $text)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(Theme.Spacing.sm)
                .terminalCard()
        }
    }
}

// MARK: - View Model

@MainActor
class BuilderCreateContractViewModel: ObservableObject {
    @Published var selectedClient: ClientInfo?
    @Published var showingClientPicker = false
    
    @Published var projectTitle = ""
    @Published var projectDescription = ""
    @Published var startDate = ""
    @Published var endDate = ""
    
    @Published var deliverables: [String] = [""]
    
    @Published var totalAmount: Double = 0
    @Published var selectedPaymentStructure: PaymentStructureOption = .upfront
    @Published var customMilestones: [CustomMilestone] = [
        CustomMilestone(percentage: 50, description: "Initial payment"),
        CustomMilestone(percentage: 50, description: "Final payment")
    ]
    
    @Published var additionalTerms = ""
    
    var isValid: Bool {
        selectedClient != nil &&
        !projectTitle.isEmpty &&
        !projectDescription.isEmpty &&
        totalAmount > 0 &&
        !deliverables.filter({ !$0.isEmpty }).isEmpty &&
        (selectedPaymentStructure != .milestones || customMilestones.totalPercentage == 100)
    }
    
    func addDeliverable() {
        deliverables.append("")
    }
    
    func removeDeliverable(at index: Int) {
        deliverables.remove(at: index)
    }
    
    func addMilestone() {
        customMilestones.append(CustomMilestone(percentage: 0, description: ""))
    }
    
    func removeMilestone(at index: Int) {
        customMilestones.remove(at: index)
    }
    
    func calculateBreakdown() -> PaymentBreakdown {
        let structure = selectedPaymentStructure.toPaymentStructure(milestones: customMilestones)
        let tempContract = Contract(
            hirerId: UUID(),
            freelancerId: MockData.shared.currentUserId,
            projectTitle: projectTitle,
            projectDescription: projectDescription,
            totalAmount: totalAmount,
            paymentStructure: structure
        )
        return tempContract.paymentBreakdown()
    }
    
    func createContract() -> Contract {
        guard let client = selectedClient else {
            fatalError("No client selected")
        }
        
        let structure = selectedPaymentStructure.toPaymentStructure(milestones: customMilestones)
        
        return Contract(
            hirerId: client.id,
            freelancerId: MockData.shared.currentUserId,
            projectTitle: projectTitle,
            projectDescription: projectDescription,
            totalAmount: totalAmount,
            paymentStructure: structure,
            milestones: structure.createMilestones(totalAmount: totalAmount),
            status: .pendingSignature
        )
    }
}

// MARK: - Client Info Model

struct ClientInfo: Identifiable, Codable {
    let id: UUID
    let displayName: String
    let email: String
    let avatarURL: String?
}

// MARK: - Client Picker View

struct ClientPickerView: View {
    @Binding var selectedClient: ClientInfo?
    @Environment(\.dismiss) private var dismiss
    
    // Mock clients - in production, fetch from your backend
    private let mockClients = [
        ClientInfo(id: UUID(), displayName: "TechCorp Inc", email: "contact@techcorp.com", avatarURL: nil),
        ClientInfo(id: UUID(), displayName: "StartupXYZ", email: "hello@startupxyz.com", avatarURL: nil),
        ClientInfo(id: UUID(), displayName: "Sarah Johnson", email: "sarah@example.com", avatarURL: nil),
        ClientInfo(id: UUID(), displayName: "Mike Chen", email: "mike@example.com", avatarURL: nil)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.sm) {
                        ForEach(mockClients) { client in
                            Button(action: {
                                selectedClient = client
                                dismiss()
                            }) {
                                HStack(spacing: Theme.Spacing.sm) {
                                    AvatarView(displayName: client.displayName, size: 40)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(client.displayName)
                                            .font(Theme.Typography.body.weight(.semibold))
                                            .foregroundColor(Theme.Colors.textPrimary)
                                        
                                        Text(client.email)
                                            .font(Theme.Typography.caption)
                                            .foregroundColor(Theme.Colors.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedClient?.id == client.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Theme.Colors.accent)
                                    }
                                }
                                .padding(Theme.Spacing.md)
                                .terminalCard()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .navigationTitle("Select Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }
            }
        }
    }
}

#Preview {
    BuilderCreateContractView(onContractCreated: { _ in })
}
