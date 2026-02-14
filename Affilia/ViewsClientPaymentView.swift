//
//  ClientPaymentView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI
import PassKit

/// Client-facing view for paying contracts via Apple Pay
struct ClientPaymentView: View {
    let contract: Contract
    let milestone: Milestone?
    let onPaymentComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var paymentManager = PaymentManager.shared
    @State private var isProcessingPayment = false
    @State private var showingPaymentSuccess = false
    @State private var showingPaymentError = false
    @State private var errorMessage = ""
    
    private var paymentAmount: Double {
        milestone?.amount ?? contract.hirerTotalCost
    }
    
    private var paymentTitle: String {
        if let milestone = milestone {
            return "\(contract.projectTitle) - \(milestone.title)"
        }
        return contract.projectTitle
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        // Header
                        headerSection
                        
                        Divider().background(Theme.Colors.border)
                        
                        // Contract details
                        contractDetailsSection
                        
                        Divider().background(Theme.Colors.border)
                        
                        // Payment breakdown
                        paymentBreakdownSection
                        
                        Divider().background(Theme.Colors.border)
                        
                        // Apple Pay section
                        applePaySection
                        
                        // Terms
                        termsSection
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .navigationTitle("Complete Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .alert("Payment Successful", isPresented: $showingPaymentSuccess) {
                Button("Done") {
                    onPaymentComplete()
                    dismiss()
                }
            } message: {
                Text("Your payment has been processed successfully!")
            }
            .alert("Payment Failed", isPresented: $showingPaymentError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Theme.Colors.accent)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("CONTRACT PAYMENT")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    Text(paymentTitle)
                        .font(Theme.Typography.heading)
                        .foregroundColor(Theme.Colors.textPrimary)
                }
            }
            
            // Amount card
            VStack(spacing: Theme.Spacing.xs) {
                Text("TOTAL AMOUNT")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Text("$\(String(format: "%.2f", paymentAmount))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.accent)
            }
            .frame(maxWidth: .infinity)
            .padding(Theme.Spacing.lg)
            .background(Theme.Colors.accent.opacity(0.1))
            .cornerRadius(Theme.CornerRadius.medium)
        }
    }
    
    // MARK: - Contract Details
    
    private var contractDetailsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("CONTRACT DETAILS")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                DetailRow(label: "Project", value: contract.projectTitle)
                DetailRow(label: "Payment Type", value: contract.paymentStructure.displayName)
                
                if let milestone = milestone {
                    DetailRow(label: "Milestone", value: milestone.title)
                    DetailRow(label: "Description", value: milestone.description)
                }
                
                DetailRow(label: "Created", value: contract.createdAt.formatted(date: .abbreviated, time: .omitted))
            }
            .padding(Theme.Spacing.md)
            .terminalCard()
        }
    }
    
    // MARK: - Payment Breakdown
    
    private var paymentBreakdownSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("PAYMENT BREAKDOWN")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            VStack(spacing: Theme.Spacing.xs) {
                if let milestone = milestone {
                    BreakdownRow(label: "Milestone Amount", amount: milestone.amount)
                } else {
                    BreakdownRow(label: "Contract Value", amount: contract.totalAmount)
                }
                
                BreakdownRow(label: "Platform Fee (5%)", amount: contract.platformFee, color: Theme.Colors.textSecondary)
                
                Divider().background(Theme.Colors.border)
                
                BreakdownRow(
                    label: "You Pay",
                    amount: paymentAmount,
                    color: Theme.Colors.textPrimary,
                    isTotal: true
                )
            }
            .padding(Theme.Spacing.md)
            .terminalCard()
        }
    }
    
    // MARK: - Apple Pay Section
    
    private var applePaySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("PAYMENT METHOD")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            if paymentManager.isApplePayAvailable {
                // Apple Pay button
                Button(action: processPayment) {
                    HStack(spacing: Theme.Spacing.sm) {
                        if isProcessingPayment {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 24))
                            Text("PAY WITH APPLE PAY")
                                .font(Theme.Typography.body.weight(.bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.lg)
                    .background(Color.black)
                    .cornerRadius(Theme.CornerRadius.medium)
                }
                .disabled(isProcessingPayment)
                
                // Security info
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 12))
                    Text("Secure payment powered by Apple Pay")
                        .font(Theme.Typography.tiny)
                }
                .foregroundColor(Theme.Colors.textSecondary)
                .padding(.top, Theme.Spacing.xs)
            } else {
                // Apple Pay not available
                VStack(spacing: Theme.Spacing.sm) {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        
                        Text("Apple Pay is not available on this device")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textPrimary)
                    }
                    .padding(Theme.Spacing.md)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.medium)
                    
                    Text("Please set up Apple Pay in your device settings to continue.")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Terms
    
    private var termsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("By completing this payment, you agree to Affilia's Terms of Service and confirm that you authorize this payment to the builder.")
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textSecondary)
            
            HStack(spacing: Theme.Spacing.xs) {
                Button("Terms of Service") {}
                Text("•")
                Button("Privacy Policy") {}
            }
            .font(Theme.Typography.tiny)
            .foregroundColor(Theme.Colors.accent)
        }
        .padding(.top, Theme.Spacing.md)
    }
    
    // MARK: - Actions
    
    private func processPayment() {
        isProcessingPayment = true
        
        paymentManager.processContractPayment(
            contract: contract,
            milestone: milestone
        ) { result in
            isProcessingPayment = false
            
            switch result {
            case .success:
                // Payment successful
                showingPaymentSuccess = true
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
            case .failure(let error):
                // Payment failed
                errorMessage = error.localizedDescription
                showingPaymentError = true
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        }
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(Theme.Typography.caption.weight(.semibold))
                .foregroundColor(Theme.Colors.textPrimary)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    ClientPaymentView(
        contract: Contract(
            hirerId: UUID(),
            freelancerId: UUID(),
            projectTitle: "iOS App Development",
            projectDescription: "Build a SwiftUI app",
            totalAmount: 50000,
            paymentStructure: .upfront,
            status: .pendingSignature
        ),
        milestone: nil,
        onPaymentComplete: {}
    )
}
