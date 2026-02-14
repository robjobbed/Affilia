//
//  CreateAgentListingView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI
internal import Combine

/// View for developers to list their AI agents for hire
struct CreateAgentListingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateAgentListingViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        // Introduction
                        introSection
                        
                        // Basic info
                        basicInfoSection
                        
                        // Category and capabilities
                        categorySection
                        
                        // Pricing
                        pricingSection
                        
                        // Technical details
                        technicalSection
                        
                        // Submit button
                        Button {
                            viewModel.submitListing()
                        } label: {
                            if viewModel.isSubmitting {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(Theme.Colors.background)
                            } else {
                                Text("Submit for Review")
                                    .font(Theme.Typography.body.weight(.bold))
                                    .foregroundColor(Theme.Colors.background)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Theme.Spacing.md)
                        .background(viewModel.canSubmit ? Theme.Colors.accent : Theme.Colors.textSecondary.opacity(0.3))
                        .cornerRadius(Theme.CornerRadius.medium)
                        .disabled(!viewModel.canSubmit || viewModel.isSubmitting)
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .navigationTitle("List Your Agent")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
            }
            .alert("Success!", isPresented: $viewModel.showingSuccess) {
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Your agent has been submitted for review. You'll be notified once it's approved!")
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
    
    private var introSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(Theme.Colors.accent)
                Text("List Your AI Agent")
                    .font(Theme.Typography.h3)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            Text("Share your OpenClaw bot, custom agent, or AI assistant with the Affilia community. Earn revenue when people hire your agent to work on their projects.")
                .font(Theme.Typography.small)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.accent.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.medium)
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Basic Information")
                .font(Theme.Typography.body.weight(.bold))
                .foregroundColor(Theme.Colors.textPrimary)
            
            FormField(
                label: "Agent Name",
                placeholder: "e.g., CodeClaw Pro",
                text: $viewModel.agentName
            )
            
            FormField(
                label: "Tagline",
                placeholder: "One-line description (max 60 chars)",
                text: $viewModel.tagline
            )
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Description")
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                TextEditor(text: $viewModel.description)
                    .frame(minHeight: 120)
                    .padding(Theme.Spacing.sm)
                    .background(Theme.Colors.surface)
                    .cornerRadius(Theme.CornerRadius.small)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("Describe what your agent does and what makes it special")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Category & Capabilities")
                .font(Theme.Typography.body.weight(.bold))
                .foregroundColor(Theme.Colors.textPrimary)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Category")
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Menu {
                    ForEach(AgentCategory.allCases, id: \.self) { category in
                        Button {
                            viewModel.selectedCategory = category
                        } label: {
                            Label(category.rawValue, systemImage: category.icon)
                        }
                    }
                } label: {
                    HStack {
                        if let category = viewModel.selectedCategory {
                            Label(category.rawValue, systemImage: category.icon)
                                .foregroundColor(Theme.Colors.textPrimary)
                        } else {
                            Text("Select a category")
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .font(Theme.Typography.small)
                    .padding(Theme.Spacing.sm)
                    .background(Theme.Colors.surface)
                    .cornerRadius(Theme.CornerRadius.small)
                }
            }
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack {
                    Text("Capabilities")
                        .font(Theme.Typography.small)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    Spacer()
                    
                    Button {
                        viewModel.addCapability()
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                            .font(Theme.Typography.tiny)
                            .foregroundColor(Theme.Colors.accent)
                    }
                }
                
                ForEach(viewModel.capabilities.indices, id: \.self) { index in
                    CapabilityEditor(
                        capability: $viewModel.capabilities[index],
                        onDelete: {
                            viewModel.capabilities.remove(at: index)
                        }
                    )
                }
            }
        }
    }
    
    private var pricingSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Pricing Model")
                .font(Theme.Typography.body.weight(.bold))
                .foregroundColor(Theme.Colors.textPrimary)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("How do you want to charge?")
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                ForEach(PricingType.allCases, id: \.self) { type in
                    PricingTypeButton(
                        type: type,
                        isSelected: viewModel.selectedPricingType == type,
                        action: {
                            viewModel.selectedPricingType = type
                        }
                    )
                }
            }
            
            if viewModel.selectedPricingType != nil {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Price")
                        .font(Theme.Typography.small)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    HStack {
                        Text("$")
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        TextField("0.00", text: $viewModel.priceAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.plain)
                        
                        if let type = viewModel.selectedPricingType {
                            Text(type.suffix)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                    }
                    .padding(Theme.Spacing.sm)
                    .background(Theme.Colors.surface)
                    .cornerRadius(Theme.CornerRadius.small)
                }
                
                Text("Platform keeps 5% fee. You receive 95% of each payment.")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .padding(.horizontal, Theme.Spacing.xs)
            }
        }
    }
    
    private var technicalSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Technical Details")
                .font(Theme.Typography.body.weight(.bold))
                .foregroundColor(Theme.Colors.textPrimary)
            
            FormField(
                label: "Framework",
                placeholder: "e.g., OpenClaw, LangChain, Custom",
                text: $viewModel.framework
            )
            
            FormField(
                label: "Model (Optional)",
                placeholder: "e.g., GPT-4, Claude, Local LLM",
                text: $viewModel.model
            )
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Hosting")
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                ForEach([AgentHosting.cloud, .selfHosted, .hybrid], id: \.self) { hosting in
                    Button {
                        viewModel.selectedHosting = hosting
                    } label: {
                        HStack {
                            Image(systemName: hosting.icon)
                                .foregroundColor(Theme.Colors.accent)
                            
                            Text(hosting.rawValue)
                                .font(Theme.Typography.small)
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Spacer()
                            
                            if viewModel.selectedHosting == hosting {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Theme.Colors.accent)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(Theme.Colors.border)
                            }
                        }
                        .padding(Theme.Spacing.sm)
                        .background(viewModel.selectedHosting == hosting ?
                                    Theme.Colors.accent.opacity(0.1) : Theme.Colors.surface)
                        .cornerRadius(Theme.CornerRadius.small)
                    }
                }
            }
            
            FormField(
                label: "Repository URL (Optional)",
                placeholder: "https://github.com/...",
                text: $viewModel.repositoryURL
            )
            
            FormField(
                label: "Documentation URL (Optional)",
                placeholder: "https://...",
                text: $viewModel.documentationURL
            )
            
            Toggle(isOn: $viewModel.requiresAPIKey) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Requires API Key")
                        .font(Theme.Typography.small)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("Check if users need to provide their own API keys")
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .tint(Theme.Colors.accent)
        }
    }
}

// MARK: - Helper Views

private struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(label)
                .font(Theme.Typography.small)
                .foregroundColor(Theme.Colors.textSecondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .padding(Theme.Spacing.sm)
                .background(Theme.Colors.surface)
                .cornerRadius(Theme.CornerRadius.small)
        }
    }
}

struct PricingTypeButton: View {
    let type: PricingType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.title)
                        .font(Theme.Typography.small.weight(.semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text(type.description)
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.Colors.accent)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(Theme.Colors.border)
                }
            }
            .padding(Theme.Spacing.sm)
            .background(isSelected ? Theme.Colors.accent.opacity(0.1) : Theme.Colors.surface)
            .cornerRadius(Theme.CornerRadius.small)
        }
    }
}

struct CapabilityEditor: View {
    @Binding var capability: AgentCapability
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack {
                TextField("Capability name", text: $capability.name)
                    .font(Theme.Typography.small.weight(.semibold))
                    .textFieldStyle(.plain)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            TextField("Description", text: $capability.description)
                .font(Theme.Typography.tiny)
                .textFieldStyle(.plain)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.sm)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.small)
    }
}

// MARK: - Pricing Type

enum PricingType: CaseIterable {
    case perTask
    case hourly
    case monthly
    
    var title: String {
        switch self {
        case .perTask: return "Per Task"
        case .hourly: return "Hourly"
        case .monthly: return "Monthly Subscription"
        }
    }
    
    var description: String {
        switch self {
        case .perTask: return "Charge a fixed price per task"
        case .hourly: return "Charge by the hour"
        case .monthly: return "Monthly subscription fee"
        }
    }
    
    var suffix: String {
        switch self {
        case .perTask: return "per task"
        case .hourly: return "per hour"
        case .monthly: return "per month"
        }
    }
}

// MARK: - View Model

@MainActor
class CreateAgentListingViewModel: ObservableObject {
    @Published var agentName = ""
    @Published var tagline = ""
    @Published var description = ""
    @Published var selectedCategory: AgentCategory?
    @Published var capabilities: [AgentCapability] = []
    @Published var selectedPricingType: PricingType?
    @Published var priceAmount = ""
    @Published var framework = ""
    @Published var model = ""
    @Published var selectedHosting: AgentHosting = .cloud
    @Published var repositoryURL = ""
    @Published var documentationURL = ""
    @Published var requiresAPIKey = false
    
    @Published var isSubmitting = false
    @Published var showingSuccess = false
    @Published var showingError = false
    @Published var errorMessage: String?
    
    var canSubmit: Bool {
        !agentName.isEmpty &&
        !tagline.isEmpty &&
        !description.isEmpty &&
        selectedCategory != nil &&
        !capabilities.isEmpty &&
        selectedPricingType != nil &&
        !priceAmount.isEmpty &&
        Double(priceAmount) != nil &&
        !framework.isEmpty
    }
    
    func addCapability() {
        capabilities.append(AgentCapability(name: "", description: ""))
    }
    
    func submitListing() {
        guard canSubmit else { return }
        
        isSubmitting = true
        
        // Simulate submission
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            
            self.isSubmitting = false
            
            // In production: Create AgentListing, submit to backend for review
            
            self.showingSuccess = true
        }
    }
}

#Preview {
    CreateAgentListingView()
}
