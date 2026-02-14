//
//  ContactSupportView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/4/26.
//

import SwiftUI
import MessageUI

/// Contact Support view with email functionality
struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var subject = ""
    @State private var message = ""
    @State private var showingMailView = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let supportEmail = "rob@solomine.io"
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Header
                    VStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.Colors.accent)
                        
                        Text("Contact Support")
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("We're here to help! Send us an email and we'll get back to you as soon as possible.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.Spacing.md)
                    }
                    .padding(.top, Theme.Spacing.xl)
                    
                    // Contact Options
                    VStack(spacing: Theme.Spacing.md) {
                        // Email Option
                        VStack(spacing: Theme.Spacing.sm) {
                            Text("Email Us Directly")
                                .font(Theme.Typography.heading)
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Button {
                                openEmail()
                            } label: {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                    Text(supportEmail)
                                        .font(Theme.Typography.body.weight(.semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(Theme.Spacing.md)
                                .background(Theme.Colors.accent)
                                .foregroundColor(.white)
                                .cornerRadius(Theme.CornerRadius.medium)
                            }
                        }
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.surface)
                        .cornerRadius(Theme.CornerRadius.large)
                        
                        // Common Topics
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Text("Common Topics")
                                .font(Theme.Typography.heading)
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            SupportTopicButton(
                                icon: "person.crop.circle.badge.questionmark",
                                title: "Account Issues",
                                description: "Problems with login or account settings"
                            ) {
                                openEmailWithSubject("Account Issues")
                            }
                            
                            SupportTopicButton(
                                icon: "dollarsign.circle",
                                title: "Payment Questions",
                                description: "Billing, refunds, or payment issues"
                            ) {
                                openEmailWithSubject("Payment Questions")
                            }
                            
                            SupportTopicButton(
                                icon: "exclamationmark.triangle",
                                title: "Report a Problem",
                                description: "Technical issues or bugs"
                            ) {
                                openEmailWithSubject("Report a Problem")
                            }
                            
                            SupportTopicButton(
                                icon: "flag.fill",
                                title: "Report Abuse",
                                description: "Report inappropriate behavior or content"
                            ) {
                                openEmailWithSubject("Report Abuse")
                            }
                            
                            SupportTopicButton(
                                icon: "lightbulb.fill",
                                title: "Feature Request",
                                description: "Suggest new features or improvements"
                            ) {
                                openEmailWithSubject("Feature Request")
                            }
                            
                            SupportTopicButton(
                                icon: "questionmark.circle",
                                title: "General Question",
                                description: "Other questions or feedback"
                            ) {
                                openEmailWithSubject("General Question")
                            }
                        }
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.surface)
                        .cornerRadius(Theme.CornerRadius.large)
                        
                        // Response Time
                        VStack(spacing: Theme.Spacing.sm) {
                            HStack(spacing: Theme.Spacing.sm) {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(Theme.Colors.accent)
                                Text("Response Time")
                                    .font(Theme.Typography.body.weight(.semibold))
                                    .foregroundColor(Theme.Colors.textPrimary)
                            }
                            
                            Text("We typically respond within 24-48 hours during business days.")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.accent.opacity(0.1))
                        .cornerRadius(Theme.CornerRadius.medium)
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    Spacer()
                }
            }
        }
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Unable to Send Email", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Email Functions
    
    private func openEmail() {
        let email = supportEmail
        guard let url = URL(string: "mailto:\(email)") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            alertMessage = "Please email us at \(supportEmail)"
            showingAlert = true
        }
    }
    
    private func openEmailWithSubject(_ subject: String) {
        let email = supportEmail
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject
        guard let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            alertMessage = "Please email us at \(supportEmail) with subject: \(subject)"
            showingAlert = true
        }
    }
}

// MARK: - Supporting Views

private struct SupportTopicButton: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Theme.Colors.accent)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Theme.Typography.body.weight(.semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text(description)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.background)
            .cornerRadius(Theme.CornerRadius.medium)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ContactSupportView()
    }
}
