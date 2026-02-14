//
//  RequestVerificationView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/4/26.
//

import SwiftUI

/// Builder-facing view to request Verified Coder status
struct RequestVerificationView: View {
    
    @ObservedObject var authManager = AuthenticationManager.shared
    @StateObject private var verificationManager = VerificationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingConfirmation = false
    @State private var requestSubmitted = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Header
                    VStack(alignment: .center, spacing: Theme.Spacing.md) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.Colors.accent)
                        
                        Text("BECOME A VERIFIED CODER")
                            .font(Theme.Typography.h2)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("Get the verified badge to stand out and build trust with clients")
                            .font(Theme.Typography.small)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, Theme.Spacing.md)
                    
                    Divider()
                        .background(Theme.Colors.border)
                    
                    // Benefits
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("BENEFITS")
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        BenefitRow(
                            icon: "star.fill",
                            title: "Stand Out",
                            description: "Verified badge on your profile"
                        )
                        
                        BenefitRow(
                            icon: "person.badge.shield.checkmark.fill",
                            title: "Build Trust",
                            description: "Show clients you're vetted by Affilia"
                        )
                        
                        BenefitRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "More Opportunities",
                            description: "Get prioritized in search results"
                        )
                        
                        BenefitRow(
                            icon: "dollarsign.circle.fill",
                            title: "Higher Rates",
                            description: "Verified coders earn 30% more on average"
                        )
                    }
                    
                    Divider()
                        .background(Theme.Colors.border)
                    
                    // Requirements
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("REQUIREMENTS")
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        RequirementRow(
                            icon: "briefcase.fill",
                            text: "Complete portfolio with real projects",
                            isMet: hasPortfolio
                        )
                        
                        RequirementRow(
                            icon: "star.leadinghalf.filled",
                            text: "Strong GitHub profile with code samples",
                            isMet: hasGitHub
                        )
                        
                        RequirementRow(
                            icon: "checkmark.circle.fill",
                            text: "Verified skills matching your expertise",
                            isMet: hasSkills
                        )
                        
                        RequirementRow(
                            icon: "person.fill.checkmark",
                            text: "Professional profile and communication",
                            isMet: true // Always assume this is met
                        )
                    }
                    
                    Divider()
                        .background(Theme.Colors.border)
                    
                    // Current Status
                    if let userId = authManager.currentUser?.id {
                        if let existingRequest = verificationManager.getVerificationRequest(for: userId) {
                            StatusCard(request: existingRequest)
                        } else if authManager.currentUser?.freelancerProfile?.isVerifiedCoder == true {
                            VStack(spacing: Theme.Spacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Theme.Colors.accent)
                                
                                Text("YOU'RE VERIFIED!")
                                    .font(Theme.Typography.h3)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                
                                if let verifiedDate = authManager.currentUser?.freelancerProfile?.verificationDate {
                                    Text("Verified on \(verifiedDate.formatted(date: .long, time: .omitted))")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(Theme.Spacing.lg)
                            .background(Theme.Colors.accent.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                    .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                            )
                            .cornerRadius(Theme.CornerRadius.medium)
                        } else {
                            // Submit button
                            Button {
                                showingConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "paperplane.fill")
                                    Text("SUBMIT VERIFICATION REQUEST")
                                }
                                .font(Theme.Typography.small)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(Theme.Spacing.md)
                                .background(allRequirementsMet ? Theme.Colors.accent : Theme.Colors.accentDimmed)
                                .cornerRadius(Theme.CornerRadius.medium)
                            }
                            .disabled(!allRequirementsMet)
                            
                            if !allRequirementsMet {
                                Text("Complete all requirements to request verification")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
            }
            .alert("Submit Verification Request", isPresented: $showingConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Submit") {
                    submitVerificationRequest()
                }
            } message: {
                Text("Our team will review your profile within 2-3 business days. You'll be notified via email when your verification is complete.")
            }
            .alert("Request Submitted!", isPresented: $requestSubmitted) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your verification request has been submitted. We'll review your profile and get back to you soon!")
            }
        }
    }
    
    // MARK: - Requirement Checks
    
    private var hasPortfolio: Bool {
        guard let portfolio = authManager.currentUser?.freelancerProfile?.portfolioProjects else {
            return false
        }
        return portfolio.count >= 2 // Require at least 2 projects
    }
    
    private var hasGitHub: Bool {
        // In production, check if GitHub is linked and has activity
        return authManager.githubProfile != nil
    }
    
    private var hasSkills: Bool {
        guard let skills = authManager.currentUser?.freelancerProfile?.skills else {
            return false
        }
        return skills.count >= 3 // Require at least 3 skills
    }
    
    private var allRequirementsMet: Bool {
        hasPortfolio && hasGitHub && hasSkills
    }
    
    // MARK: - Actions
    
    private func submitVerificationRequest() {
        guard let userId = authManager.currentUser?.id else { return }
        
        verificationManager.requestVerification(for: userId)
        requestSubmitted = true
    }
}

// MARK: - Supporting Views

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Theme.Colors.accent)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(title)
                    .font(Theme.Typography.small)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
        )
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

struct RequirementRow: View {
    let icon: String
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isMet ? Theme.Colors.accent : Theme.Colors.textSecondary.opacity(0.5))
                .frame(width: 24)
            
            Text(text)
                .font(Theme.Typography.small)
                .foregroundColor(isMet ? Theme.Colors.textPrimary : Theme.Colors.textSecondary)
            
            Spacer()
            
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? Theme.Colors.accent : Theme.Colors.textSecondary.opacity(0.3))
        }
        .padding(Theme.Spacing.sm)
    }
}

struct StatusCard: View {
    let request: VerificationRequest
    
    var statusColor: Color {
        switch request.status {
        case .pending: return .orange
        case .approved: return Theme.Colors.accent
        case .rejected: return .red
        }
    }
    
    var statusIcon: String {
        switch request.status {
        case .pending: return "clock.fill"
        case .approved: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        }
    }
    
    var statusMessage: String {
        switch request.status {
        case .pending: return "Your verification request is being reviewed"
        case .approved: return "Your verification has been approved!"
        case .rejected: return "Your verification request was not approved"
        }
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: statusIcon)
                .font(.system(size: 40))
                .foregroundColor(statusColor)
            
            Text(statusMessage)
                .font(Theme.Typography.small)
                .foregroundColor(Theme.Colors.textPrimary)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Submitted: \(request.submittedDate.formatted(date: .abbreviated, time: .omitted))")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            if let notes = request.reviewNotes, request.status != .pending {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Review Notes:")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    Text(notes)
                        .font(Theme.Typography.small)
                        .foregroundColor(Theme.Colors.textPrimary)
                }
                .padding(Theme.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.Colors.surface)
                .cornerRadius(Theme.CornerRadius.small)
            }
        }
        .padding(Theme.Spacing.lg)
        .background(statusColor.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .stroke(statusColor, lineWidth: Theme.BorderWidth.thin)
        )
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

// MARK: - Preview

#Preview {
    RequestVerificationView()
}
