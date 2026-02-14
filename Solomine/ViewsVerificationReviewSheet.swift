//
//  VerificationReviewSheet.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/4/26.
//

import SwiftUI

/// Detailed review interface for admin to approve/reject verification requests
struct VerificationReviewSheet: View {
    
    let request: VerificationRequest
    let onDismiss: () -> Void
    
    @StateObject private var verificationManager = VerificationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    // Review form state
    @State private var portfolioReviewed = false
    @State private var githubReviewed = false
    @State private var skillsVerified = false
    @State private var professionalismScore = 3
    @State private var reviewNotes = ""
    @State private var showingApproveConfirmation = false
    @State private var showingRejectConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("VERIFICATION REVIEW")
                            .font(Theme.Typography.h2)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Request #\(request.id.uuidString.prefix(8))")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        HStack {
                            Text("Submitted:")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            Text(request.submittedDate.formatted(date: .long, time: .omitted))
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textPrimary)
                        }
                    }
                    .padding(.bottom, Theme.Spacing.sm)
                    
                    Divider()
                        .background(Theme.Colors.border)
                    
                    // Builder Information
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("BUILDER INFORMATION")
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        VerificationInfoRow(label: "User ID", value: request.userId.uuidString.prefix(8).description)
                        
                        // In production, you'd fetch the actual user profile here
                        Text("Review the builder's profile, portfolio, and GitHub to verify their skills and professionalism.")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .padding(.vertical, Theme.Spacing.sm)
                            .padding(.horizontal, Theme.Spacing.md)
                            .background(Theme.Colors.accent.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                    .stroke(Theme.Colors.accent.opacity(0.2), lineWidth: Theme.BorderWidth.thin)
                            )
                            .cornerRadius(Theme.CornerRadius.small)
                    }
                    
                    Divider()
                        .background(Theme.Colors.border)
                    
                    // Review Checklist (only show if pending)
                    if request.status == .pending {
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Text("VERIFICATION CHECKLIST")
                                .font(Theme.Typography.title)
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            ChecklistItem(
                                isChecked: $portfolioReviewed,
                                label: "Portfolio Reviewed",
                                description: "Verified portfolio quality and project authenticity"
                            )
                            
                            ChecklistItem(
                                isChecked: $githubReviewed,
                                label: "GitHub Profile Reviewed",
                                description: "Checked GitHub activity and code quality"
                            )
                            
                            ChecklistItem(
                                isChecked: $skillsVerified,
                                label: "Skills Verified",
                                description: "Confirmed listed skills match demonstrated work"
                            )
                            
                            // Professionalism Score
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("PROFESSIONALISM SCORE")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                HStack(spacing: Theme.Spacing.sm) {
                                    ForEach(1...5, id: \.self) { score in
                                        Button {
                                            professionalismScore = score
                                        } label: {
                                            Image(systemName: score <= professionalismScore ? "star.fill" : "star")
                                                .font(.system(size: 24))
                                                .foregroundColor(score <= professionalismScore ? Theme.Colors.accent : Theme.Colors.textSecondary.opacity(0.3))
                                        }
                                    }
                                    
                                    Text("\(professionalismScore)/5")
                                        .font(Theme.Typography.small)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                        .padding(.leading, Theme.Spacing.sm)
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
                        
                        Divider()
                            .background(Theme.Colors.border)
                        
                        // Review Notes
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("REVIEW NOTES")
                                .font(Theme.Typography.title)
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            TextEditor(text: $reviewNotes)
                                .font(Theme.Typography.small)
                                .foregroundColor(Theme.Colors.textPrimary)
                                .frame(minHeight: 100)
                                .padding(Theme.Spacing.sm)
                                .background(Theme.Colors.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                        .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
                                )
                                .cornerRadius(Theme.CornerRadius.medium)
                            
                            Text("Internal notes about this verification decision")
                                .font(Theme.Typography.tiny)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        
                        // Action Buttons
                        HStack(spacing: Theme.Spacing.md) {
                            Button {
                                showingRejectConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                    Text("REJECT")
                                }
                                .font(Theme.Typography.small)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(Theme.Spacing.md)
                                .background(Color.red.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                        .stroke(Color.red, lineWidth: Theme.BorderWidth.thin)
                                )
                                .cornerRadius(Theme.CornerRadius.medium)
                            }
                            
                            Button {
                                showingApproveConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("APPROVE")
                                }
                                .font(Theme.Typography.small)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(Theme.Spacing.md)
                                .background(Theme.Colors.accent)
                                .cornerRadius(Theme.CornerRadius.medium)
                            }
                            .disabled(!allChecklistItemsReviewed)
                            .opacity(allChecklistItemsReviewed ? 1.0 : 0.5)
                        }
                        .padding(.top, Theme.Spacing.md)
                    } else {
                        // Show review results for approved/rejected requests
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Text("REVIEW DETAILS")
                                .font(Theme.Typography.title)
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            if let reviewedDate = request.reviewedDate {
                                VerificationInfoRow(label: "Reviewed On", value: reviewedDate.formatted(date: .long, time: .omitted))
                            }
                            
                            if let reviewedBy = request.reviewedBy {
                                VerificationInfoRow(label: "Reviewed By", value: reviewedBy)
                            }
                            
                            if request.portfolioReviewed || request.githubReviewed || request.skillsVerified {
                                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                    Text("Verified Items:")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    
                                    if request.portfolioReviewed {
                                        Text("✓ Portfolio Reviewed")
                                            .font(Theme.Typography.small)
                                            .foregroundColor(Theme.Colors.accent)
                                    }
                                    if request.githubReviewed {
                                        Text("✓ GitHub Reviewed")
                                            .font(Theme.Typography.small)
                                            .foregroundColor(Theme.Colors.accent)
                                    }
                                    if request.skillsVerified {
                                        Text("✓ Skills Verified")
                                            .font(Theme.Typography.small)
                                            .foregroundColor(Theme.Colors.accent)
                                    }
                                }
                            }
                            
                            if let score = request.professionalismScore {
                                VerificationInfoRow(label: "Professionalism", value: "\(score)/5")
                            }
                            
                            if let notes = request.reviewNotes {
                                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                    Text("Notes:")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    
                                    Text(notes)
                                        .font(Theme.Typography.small)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                        .padding(Theme.Spacing.sm)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Theme.Colors.surface)
                                        .cornerRadius(Theme.CornerRadius.small)
                                }
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
                .padding(Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
            }
            .alert("Approve Verification", isPresented: $showingApproveConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Approve") {
                    approveVerification()
                }
            } message: {
                Text("Are you sure you want to approve this builder as a Verified Coder?")
            }
            .alert("Reject Verification", isPresented: $showingRejectConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reject", role: .destructive) {
                    rejectVerification()
                }
            } message: {
                Text("Are you sure you want to reject this verification request?")
            }
        }
    }
    
    private var allChecklistItemsReviewed: Bool {
        portfolioReviewed && githubReviewed && skillsVerified
    }
    
    private func approveVerification() {
        verificationManager.approveVerification(
            requestId: request.id,
            reviewedBy: "admin@solomine.app", // In production, use actual admin ID
            notes: reviewNotes,
            portfolioReviewed: portfolioReviewed,
            githubReviewed: githubReviewed,
            skillsVerified: skillsVerified,
            professionalismScore: professionalismScore
        )
        onDismiss()
    }
    
    private func rejectVerification() {
        verificationManager.rejectVerification(
            requestId: request.id,
            reviewedBy: "admin@solomine.app", // In production, use actual admin ID
            reason: reviewNotes.isEmpty ? "Did not meet verification criteria" : reviewNotes
        )
        onDismiss()
    }
}

// MARK: - Supporting Views

private struct VerificationInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(Theme.Typography.small)
                .foregroundColor(Theme.Colors.textPrimary)
        }
    }
}

private struct ChecklistItem: View {
    @Binding var isChecked: Bool
    let label: String
    let description: String
    
    var body: some View {
        Button {
            isChecked.toggle()
        } label: {
            HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                    .foregroundColor(isChecked ? Theme.Colors.accent : Theme.Colors.textSecondary)
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(label)
                        .font(Theme.Typography.small)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .fontWeight(.semibold)
                    
                    Text(description)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
            }
            .padding(Theme.Spacing.md)
            .background(isChecked ? Theme.Colors.accent.opacity(0.05) : Theme.Colors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(isChecked ? Theme.Colors.accent : Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
            )
            .cornerRadius(Theme.CornerRadius.medium)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VerificationReviewSheet(
        request: VerificationRequest(
            userId: UUID(),
            status: .pending
        ),
        onDismiss: {}
    )
}
