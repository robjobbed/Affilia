//
//  HireFreelancerView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI
import PassKit

struct HireFreelancerView: View {
    let freelancer: FreelancerProfile
    @Environment(\.dismiss) private var dismiss
    @StateObject private var paymentManager = PaymentManager.shared
    
    @State private var selectedAmount: Double
    @State private var customAmount: String = ""
    @State private var projectDescription: String = ""
    @State private var showingPaymentSheet = false
    @State private var paymentSuccess = false
    @State private var errorMessage: String?
    
    init(freelancer: FreelancerProfile) {
        self.freelancer = freelancer
        _selectedAmount = State(initialValue: freelancer.hourlyRate ?? 1000)
    }
    
    var quickAmounts: [Double] {
        if let hourly = freelancer.hourlyRate {
            return [hourly * 10, hourly * 20, hourly * 40] // 10, 20, 40 hours
        } else if let project = freelancer.projectBasedPricing {
            return [project * 0.25, project * 0.5, project] // 25%, 50%, 100% down
        }
        return [500, 1000, 2500]
    }
    
    var totalWithFee: Double {
        selectedAmount * 1.05 // 5% platform fee
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                if paymentSuccess {
                    PaymentSuccessView(freelancer: freelancer, amount: selectedAmount)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                            // Freelancer info
                            HStack(spacing: Theme.Spacing.sm) {
                                AvatarView(displayName: freelancer.displayName, size: 50)
                                
                                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                    Text(freelancer.displayName)
                                        .font(Theme.Typography.title)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                    
                                    Text(freelancer.handle)
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.accent)
                                }
                                
                                Spacer()
                            }
                            .padding(Theme.Spacing.md)
                            .terminalCard()
                            
                            // Amount selection
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                SectionHeader("Payment Amount")
                                
                                // Quick select amounts
                                HStack(spacing: Theme.Spacing.sm) {
                                    ForEach(quickAmounts, id: \.self) { amount in
                                        Button(action: {
                                            selectedAmount = amount
                                            customAmount = ""
                                        }) {
                                            Text("$\(Int(amount))")
                                                .font(Theme.Typography.caption)
                                                .foregroundColor(selectedAmount == amount ? Theme.Colors.background : Theme.Colors.accent)
                                                .padding(.horizontal, Theme.Spacing.sm)
                                                .padding(.vertical, Theme.Spacing.sm)
                                                .frame(maxWidth: .infinity)
                                                .background(selectedAmount == amount ? Theme.Colors.accent : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                        .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                                                )
                                                .cornerRadius(Theme.CornerRadius.small)
                                        }
                                    }
                                }
                                
                                // Custom amount input
                                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                    Text("OR ENTER CUSTOM AMOUNT:")
                                        .font(Theme.Typography.tiny)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    
                                    HStack {
                                        Text("$")
                                            .font(Theme.Typography.body)
                                            .foregroundColor(Theme.Colors.accent)
                                        
                                        TextField("", text: $customAmount, prompt: Text("0.00").foregroundColor(Theme.Colors.textSecondary))
                                            .font(Theme.Typography.body)
                                            .foregroundColor(Theme.Colors.textPrimary)
                                            .keyboardType(.decimalPad)
                                            .onChange(of: customAmount) { _, newValue in
                                                if let amount = Double(newValue), amount > 0 {
                                                    selectedAmount = amount
                                                }
                                            }
                                    }
                                    .padding(Theme.Spacing.sm)
                                    .background(Theme.Colors.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                            .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
                                    )
                                    .cornerRadius(Theme.CornerRadius.medium)
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                            
                            // Project description
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                SectionHeader("Project Details")
                                
                                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                    Text("DESCRIPTION:")
                                        .font(Theme.Typography.tiny)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    
                                    TextEditor(text: $projectDescription)
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                        .frame(height: 100)
                                        .padding(Theme.Spacing.sm)
                                        .scrollContentBackground(.hidden)
                                        .background(Theme.Colors.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                                .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
                                        )
                                        .cornerRadius(Theme.CornerRadius.medium)
                                    
                                    if projectDescription.isEmpty {
                                        Text("> briefly describe the project or work needed_")
                                            .font(Theme.Typography.tiny)
                                            .foregroundColor(Theme.Colors.textSecondary)
                                            .padding(.horizontal, Theme.Spacing.sm)
                                    }
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                            
                            // Payment breakdown
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                SectionHeader("Payment Breakdown")
                                
                                VStack(spacing: Theme.Spacing.sm) {
                                    PaymentRow(label: "PAYMENT TO FREELANCER", amount: selectedAmount)
                                    PaymentRow(label: "PLATFORM FEE (5%)", amount: selectedAmount * 0.05)
                                    
                                    Divider()
                                        .background(Theme.Colors.border)
                                    
                                    HStack {
                                        Text("TOTAL")
                                            .font(Theme.Typography.title)
                                            .foregroundColor(Theme.Colors.textPrimary)
                                        
                                        Spacer()
                                        
                                        Text("$\(String(format: "%.2f", totalWithFee))")
                                            .font(Theme.Typography.title)
                                            .foregroundColor(Theme.Colors.accent)
                                    }
                                }
                                .padding(Theme.Spacing.md)
                                .terminalCard()
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                            
                            // Error message
                            if let error = errorMessage {
                                Text("> error: \(error)")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.accentSecondary)
                                    .padding(Theme.Spacing.md)
                                    .terminalCard()
                                    .padding(.horizontal, Theme.Spacing.md)
                            }
                            
                            // Payment buttons
                            VStack(spacing: Theme.Spacing.sm) {
                                if paymentManager.isApplePayAvailable {
                                    Button(action: processPayment) {
                                        HStack {
                                            Image(systemName: "apple.logo")
                                                .font(.system(size: 16, weight: .semibold))
                                            Text("PAY WITH APPLE PAY")
                                        }
                                        .font(Theme.Typography.body)
                                        .foregroundColor(Theme.Colors.background)
                                        .padding(.horizontal, Theme.Spacing.md)
                                        .padding(.vertical, Theme.Spacing.sm)
                                        .frame(maxWidth: .infinity)
                                        .background(Theme.Colors.accent)
                                        .cornerRadius(Theme.CornerRadius.medium)
                                    }
                                    .disabled(selectedAmount <= 0 || projectDescription.isEmpty)
                                    .opacity(selectedAmount <= 0 || projectDescription.isEmpty ? 0.5 : 1.0)
                                } else {
                                    Text("> apple pay not available on this device")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.accentSecondary)
                                        .padding(Theme.Spacing.md)
                                        .terminalCard()
                                }
                                
                                Text("SECURE PAYMENT POWERED BY APPLE PAY")
                                    .font(Theme.Typography.tiny)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                            
                            Spacer(minLength: Theme.Spacing.xl)
                        }
                        .padding(.vertical, Theme.Spacing.md)
                    }
                }
            }
            .navigationTitle("HIRE FREELANCER")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("HIRE FREELANCER")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.accent)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .foregroundColor(Theme.Colors.accent)
                    }
                }
            }
            .toolbarBackground(Theme.Colors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
    
    private func processPayment() {
        guard selectedAmount > 0 else {
            errorMessage = "invalid amount"
            return
        }
        
        guard !projectDescription.isEmpty else {
            errorMessage = "project description required"
            return
        }
        
        errorMessage = nil
        
        paymentManager.processPayment(
            for: freelancer,
            amount: selectedAmount,
            description: projectDescription
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    withAnimation {
                        paymentSuccess = true
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct PaymentRow: View {
    let label: String
    let amount: Double
    
    var body: some View {
        HStack {
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Spacer()
            
            Text("$\(String(format: "%.2f", amount))")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textPrimary)
        }
    }
}

struct PaymentSuccessView: View {
    let freelancer: FreelancerProfile
    let amount: Double
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            
            // Success indicator
            ZStack {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .fill(Theme.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                            .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.medium)
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.Colors.accent)
            }
            
            // Success message
            VStack(spacing: Theme.Spacing.sm) {
                Text("> payment successful")
                    .font(Theme.Typography.heading)
                    .foregroundColor(Theme.Colors.accent)
                
                Text("$\(String(format: "%.2f", amount)) sent to \(freelancer.handle)")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("You'll receive a confirmation email shortly. The freelancer has been notified and will contact you soon.")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, Theme.Spacing.sm)
            }
            .padding(.horizontal, Theme.Spacing.xl)
            
            Spacer()
            
            // Actions
            VStack(spacing: Theme.Spacing.sm) {
                TerminalButton("VIEW DASHBOARD") {
                    // Navigate to dashboard
                    dismiss()
                }
                
                Button(action: { dismiss() }) {
                    Text("DONE")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .padding(.vertical, Theme.Spacing.sm)
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.bottom, Theme.Spacing.xl)
        }
    }
}

#Preview {
    HireFreelancerView(freelancer: MockData.shared.sampleFreelancers[0])
}
