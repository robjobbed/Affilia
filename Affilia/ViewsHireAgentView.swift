//
//  HireAgentView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI
internal import Combine

/// View for hiring an AI agent
struct HireAgentView: View {
    let agent: AgentListing
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: HireAgentViewModel
    
    init(agent: AgentListing) {
        self.agent = agent
        self._viewModel = StateObject(wrappedValue: HireAgentViewModel(agent: agent))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        // Agent summary
                        agentSummary
                        
                        // Project details form
                        projectDetailsSection
                        
                        // Pricing breakdown
                        pricingBreakdownSection
                        
                        // Payment method
                        paymentMethodSection
                        
                        // Terms
                        termsSection
                        
                        // Hire button
                        Button {
                            viewModel.hireAgent()
                        } label: {
                            if viewModel.isProcessing {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(Theme.Colors.background)
                            } else {
                                Text("Hire Agent")
                                    .font(Theme.Typography.body.weight(.bold))
                                    .foregroundColor(Theme.Colors.background)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Theme.Spacing.md)
                        .background(viewModel.canHire ? Theme.Colors.accent : Theme.Colors.textSecondary.opacity(0.3))
                        .cornerRadius(Theme.CornerRadius.medium)
                        .disabled(!viewModel.canHire || viewModel.isProcessing)
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .navigationTitle("Hire \(agent.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
            }
            .alert("Success!", isPresented: $viewModel.showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Agent hired successfully! They'll start working on your project shortly.")
            }
            .alert("Error", isPresented: $viewModel.showingError) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var agentSummary: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Circle()
                .fill(Theme.Colors.accent.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: agent.category.icon)
                        .font(.title3)
                        .foregroundColor(Theme.Colors.accent)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(agent.name)
                    .font(Theme.Typography.body.weight(.bold))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(agent.tagline)
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.medium)
    }
    
    private var projectDetailsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Project Details")
                .font(Theme.Typography.body.weight(.bold))
                .foregroundColor(Theme.Colors.textPrimary)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Project Title")
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                TextField("e.g., Build SwiftUI login screen", text: $viewModel.projectTitle)
                    .textFieldStyle(.plain)
                    .padding(Theme.Spacing.sm)
                    .background(Theme.Colors.surface)
                    .cornerRadius(Theme.CornerRadius.small)
            }
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Task Description")
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                TextEditor(text: $viewModel.taskDescription)
                    .frame(minHeight: 100)
                    .padding(Theme.Spacing.sm)
                    .background(Theme.Colors.surface)
                    .cornerRadius(Theme.CornerRadius.small)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            if case .hourly = agent.pricingModel {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Estimated Hours")
                        .font(Theme.Typography.small)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    TextField("e.g., 5", text: $viewModel.estimatedHours)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.plain)
                        .padding(Theme.Spacing.sm)
                        .background(Theme.Colors.surface)
                        .cornerRadius(Theme.CornerRadius.small)
                }
            }
        }
    }
    
    private var pricingBreakdownSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Pricing")
                .font(Theme.Typography.body.weight(.bold))
                .foregroundColor(Theme.Colors.textPrimary)
            
            VStack(spacing: Theme.Spacing.sm) {
                PricingRow(label: "Agent Cost", value: viewModel.agentCost)
                PricingRow(label: "Platform Fee (5%)", value: viewModel.platformFee)
                
                Divider().background(Theme.Colors.border)
                
                HStack {
                    Text("Total")
                        .font(Theme.Typography.body.weight(.bold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", viewModel.totalCost))")
                        .font(Theme.Typography.h3)
                        .foregroundColor(Theme.Colors.accent)
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.CornerRadius.medium)
        }
    }
    
    private var paymentMethodSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Payment Method")
                .font(Theme.Typography.body.weight(.bold))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Button {
                // In production, show payment method selector
            } label: {
                HStack {
                    Image(systemName: "apple.logo")
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Apple Pay")
                            .font(Theme.Typography.small.weight(.semibold))
                        Text("•••• 1234")
                            .font(Theme.Typography.tiny)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.surface)
                .cornerRadius(Theme.CornerRadius.medium)
            }
        }
    }
    
    private var termsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Toggle(isOn: $viewModel.agreedToTerms) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("I agree to the terms")
                        .font(Theme.Typography.small)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("You authorize payment and agent access to complete the specified task")
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .tint(Theme.Colors.accent)
        }
    }
}

// MARK: - Helper Views

private struct PricingRow: View {
    let label: String
    let value: Double
    
    var body: some View {
        HStack {
            Text(label)
                .font(Theme.Typography.small)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Spacer()
            
            Text("$\(String(format: "%.2f", value))")
                .font(Theme.Typography.small.weight(.semibold))
                .foregroundColor(Theme.Colors.textPrimary)
        }
    }
}

// MARK: - View Model

@MainActor
class HireAgentViewModel: ObservableObject {
    let agent: AgentListing
    
    @Published var projectTitle = ""
    @Published var taskDescription = ""
    @Published var estimatedHours = ""
    @Published var agreedToTerms = false
    
    @Published var isProcessing = false
    @Published var showingSuccess = false
    @Published var showingError = false
    @Published var errorMessage: String?
    
    init(agent: AgentListing) {
        self.agent = agent
    }
    
    var agentCost: Double {
        switch agent.pricingModel {
        case .perTask(let price):
            return price
        case .hourly(let rate):
            if let hours = Double(estimatedHours) {
                return rate * hours
            }
            return rate
        case .monthly(let price):
            return price
        case .custom:
            return 0.0
        }
    }
    
    var platformFee: Double {
        agentCost * 0.05
    }
    
    var totalCost: Double {
        agentCost + platformFee
    }
    
    var canHire: Bool {
        !projectTitle.isEmpty &&
        !taskDescription.isEmpty &&
        agreedToTerms &&
        totalCost > 0
    }
    
    func hireAgent() {
        guard canHire else { return }
        
        isProcessing = true
        
        // Simulate hiring process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            
            self.isProcessing = false
            
            // In production: Create AgentContract, process payment, start agent
            
            self.showingSuccess = true
        }
    }
}

#Preview {
    HireAgentView(agent: .sample)
}
