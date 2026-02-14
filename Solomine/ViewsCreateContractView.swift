//
//  CreateContractView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct CreateContractView: View {
    let freelancer: FreelancerProfile
    let onContractCreated: (Contract) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var projectTitle = ""
    @State private var projectDescription = ""
    @State private var totalAmount = ""
    @State private var selectedPaymentStructure: PaymentStructureOption = .upfront
    @State private var customMilestones: [CustomMilestone] = [
        CustomMilestone(percentage: 50, description: "Initial payment"),
        CustomMilestone(percentage: 50, description: "Final payment")
    ]
    @State private var showingPaymentBreakdown = false
    
    var isValid: Bool {
        !projectTitle.isEmpty &&
        !projectDescription.isEmpty &&
        Double(totalAmount) ?? 0 > 0 &&
        (selectedPaymentStructure != .milestones || customMilestones.totalPercentage == 100)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        // Freelancer info
                        freelancerHeader
                        
                        Divider().background(Theme.Colors.border)
                        
                        // Project details
                        projectDetailsSection
                        
                        Divider().background(Theme.Colors.border)
                        
                        // Payment structure
                        paymentStructureSection
                        
                        // Payment breakdown
                        if let amount = Double(totalAmount), amount > 0 {
                            paymentBreakdownCard
                        }
                        
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
        }
    }
    
    // MARK: - Freelancer Header
    
    private var freelancerHeader: some View {
        HStack(spacing: Theme.Spacing.sm) {
            AvatarView(displayName: freelancer.displayName, size: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(freelancer.displayName)
                    .font(Theme.Typography.title)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(freelancer.handle)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.accent)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Project Details
    
    private var projectDetailsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("PROJECT DETAILS")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            // Title
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Project Title")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                TextField("e.g., iOS App Development", text: $projectTitle)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .padding(Theme.Spacing.sm)
                    .terminalCard()
            }
            
            // Description
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Description")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                TextEditor(text: $projectDescription)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .frame(height: 120)
                    .scrollContentBackground(.hidden)
                    .padding(Theme.Spacing.sm)
                    .terminalCard()
            }
            
            // Total amount
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Total Contract Value")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                HStack {
                    Text("$")
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.Colors.accent)
                    TextField("50000", text: $totalAmount)
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .keyboardType(.decimalPad)
                }
                .padding(Theme.Spacing.sm)
                .terminalCard()
            }
        }
    }
    
    // MARK: - Payment Structure
    
    private var paymentStructureSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("PAYMENT STRUCTURE")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            ForEach(PaymentStructureOption.allCases, id: \.self) { option in
                PaymentStructureCard(
                    option: option,
                    isSelected: selectedPaymentStructure == option,
                    onSelect: { selectedPaymentStructure = option }
                )
            }
            
            // Custom milestones editor
            if selectedPaymentStructure == .milestones {
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
                
                Text("\(customMilestones.totalPercentage)% / 100%")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(customMilestones.totalPercentage == 100 ? Theme.Colors.accent : .red)
                
                Button(action: {
                    customMilestones.append(CustomMilestone(percentage: 0, description: ""))
                }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(Theme.Colors.accent)
                }
            }
            
            ForEach(customMilestones.indices, id: \.self) { index in
                HStack(spacing: Theme.Spacing.sm) {
                    TextField("%", value: $customMilestones[index].percentage, format: .number)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .keyboardType(.numberPad)
                        .frame(width: 50)
                        .padding(Theme.Spacing.xs)
                        .terminalCard()
                    
                    Text("%")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    TextField("Description", text: $customMilestones[index].description)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(Theme.Spacing.xs)
                        .terminalCard()
                    
                    if customMilestones.count > 1 {
                        Button(action: { customMilestones.remove(at: index) }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            if customMilestones.totalPercentage != 100 {
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
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(Theme.Colors.accent)
                Text("PAYMENT BREAKDOWN")
                    .font(Theme.Typography.caption.weight(.bold))
                    .foregroundColor(Theme.Colors.accent)
            }
            
            Divider().background(Theme.Colors.border)
            
            if let amount = Double(totalAmount) {
                let breakdown = calculateBreakdown(amount: amount)
                
                BreakdownRow(label: "Contract Value", amount: breakdown.contractValue)
                BreakdownRow(label: "Platform Fee (5%)", amount: breakdown.platformFee, color: Theme.Colors.textSecondary)
                BreakdownRow(label: "Freelancer Receives", amount: breakdown.freelancerReceives, color: Theme.Colors.accent)
                
                Divider().background(Theme.Colors.border)
                
                BreakdownRow(
                    label: breakdown.hirerPaysAdditionalFee ? "You Pay (includes fee)" : "You Pay",
                    amount: breakdown.hirerPays,
                    color: Theme.Colors.textPrimary,
                    isTotal: true
                )
                
                if breakdown.hirerPaysAdditionalFee {
                    Text("⚠️ You'll pay an additional 5% fee when paying after completion")
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.accentSecondary)
                        .padding(.top, Theme.Spacing.xs)
                }
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
    
    // MARK: - Create Button
    
    private var createContractButton: some View {
        Button(action: createContract) {
            Text("CREATE CONTRACT & SEND TO \(freelancer.displayName.uppercased())")
                .font(Theme.Typography.caption.weight(.bold))
                .foregroundColor(Theme.Colors.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.md)
                .background(isValid ? Theme.Colors.accent : Theme.Colors.textSecondary)
                .cornerRadius(Theme.CornerRadius.medium)
        }
        .disabled(!isValid)
    }
    
    // MARK: - Actions
    
    private func calculateBreakdown(amount: Double) -> PaymentBreakdown {
        let structure = selectedPaymentStructure.toPaymentStructure(milestones: customMilestones)
        let tempContract = Contract(
            hirerId: MockData.shared.currentUserId,
            freelancerId: freelancer.id,
            projectTitle: projectTitle,
            projectDescription: projectDescription,
            totalAmount: amount,
            paymentStructure: structure
        )
        return tempContract.paymentBreakdown()
    }
    
    private func createContract() {
        guard let amount = Double(totalAmount) else { return }
        
        let structure = selectedPaymentStructure.toPaymentStructure(milestones: customMilestones)
        
        let contract = Contract(
            hirerId: MockData.shared.currentUserId,
            freelancerId: freelancer.id,
            projectTitle: projectTitle,
            projectDescription: projectDescription,
            totalAmount: amount,
            paymentStructure: structure,
            milestones: structure.createMilestones(totalAmount: amount),
            status: .pendingSignature
        )
        
        onContractCreated(contract)
        dismiss()
    }
}

// MARK: - Supporting Views

struct PaymentStructureCard: View {
    let option: PaymentStructureOption
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Theme.Colors.accent : Theme.Colors.textSecondary)
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(option.displayName)
                        .font(Theme.Typography.body.weight(.semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text(option.description)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if option == .afterCompletion {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10))
                            Text("You pay additional 5% platform fee")
                                .font(Theme.Typography.tiny)
                        }
                        .foregroundColor(Theme.Colors.accentSecondary)
                        .padding(.top, Theme.Spacing.xs)
                    }
                }
                
                Spacer()
            }
            .padding(Theme.Spacing.md)
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

struct BreakdownRow: View {
    let label: String
    let amount: Double
    var color: Color = Theme.Colors.textPrimary
    var isTotal: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(isTotal ? Theme.Typography.body.weight(.bold) : Theme.Typography.body)
                .foregroundColor(color)
            Spacer()
            Text("$\(String(format: "%.2f", amount))")
                .font(isTotal ? Theme.Typography.heading : Theme.Typography.body)
                .foregroundColor(color)
        }
    }
}

// MARK: - Helper Models

enum PaymentStructureOption: CaseIterable {
    case upfront
    case milestones
    case afterCompletion
    
    var displayName: String {
        switch self {
        case .upfront: return "Pay 100% Upfront"
        case .milestones: return "Pay in Milestones"
        case .afterCompletion: return "Pay After Completion"
        }
    }
    
    var description: String {
        switch self {
        case .upfront:
            return "Pay the full contract value before work begins. Safest for freelancers."
        case .milestones:
            return "Pay in stages as milestones are completed. Balanced risk for both parties."
        case .afterCompletion:
            return "Pay only after the project is complete. You'll cover the 5% platform fee."
        }
    }
    
    func toPaymentStructure(milestones: [CustomMilestone]) -> PaymentStructure {
        switch self {
        case .upfront:
            return .upfront
        case .afterCompletion:
            return .afterCompletion
        case .milestones:
            let percentages = milestones.map { MilestonePercentage(percentage: Double($0.percentage) / 100.0, description: $0.description) }
            return .milestones(percentages)
        }
    }
}

struct CustomMilestone: Identifiable {
    let id = UUID()
    var percentage: Int
    var description: String
}

extension Array where Element == CustomMilestone {
    var totalPercentage: Int {
        reduce(0) { $0 + $1.percentage }
    }
}

extension PaymentStructure {
    func createMilestones(totalAmount: Double) -> [Milestone] {
        switch self {
        case .upfront:
            return [
                Milestone(
                    contractId: UUID(),
                    title: "Full Payment",
                    description: "100% upfront payment",
                    amount: totalAmount,
                    percentage: 1.0,
                    order: 1
                )
            ]
        case .afterCompletion:
            return [
                Milestone(
                    contractId: UUID(),
                    title: "Final Payment",
                    description: "Payment upon project completion",
                    amount: totalAmount,
                    percentage: 1.0,
                    order: 1
                )
            ]
        case .milestones(let percentages):
            return percentages.enumerated().map { index, percentage in
                Milestone(
                    contractId: UUID(),
                    title: "Milestone \(index + 1)",
                    description: percentage.description,
                    amount: totalAmount * percentage.percentage,
                    percentage: percentage.percentage,
                    order: index + 1
                )
            }
        }
    }
}

#Preview {
    CreateContractView(
        freelancer: MockData.shared.sampleFreelancers.first!,
        onContractCreated: { _ in }
    )
}
