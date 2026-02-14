//
//  AdminVerificationView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/4/26.
//

import SwiftUI

/// Admin interface for reviewing and approving builder verification requests
struct AdminVerificationView: View {
    
    @StateObject private var verificationManager = VerificationManager.shared
    @State private var selectedTab: Tab = .pending
    @State private var selectedRequest: VerificationRequest?
    @State private var showingReviewSheet = false
    
    enum Tab: String, CaseIterable {
        case pending = "PENDING"
        case approved = "APPROVED"
        case rejected = "REJECTED"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: Theme.Spacing.sm) {
                    Text("VERIFICATION REVIEW")
                        .font(Theme.Typography.h2)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("\(verificationManager.pendingRequests.count) pending requests")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .padding(Theme.Spacing.md)
                .frame(maxWidth: .infinity)
                .background(Theme.Colors.surface)
                .overlay(
                    Rectangle()
                        .frame(height: Theme.BorderWidth.thin)
                        .foregroundColor(Theme.Colors.border),
                    alignment: .bottom
                )
                
                // Tab Selector
                HStack(spacing: 0) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        } label: {
                            VStack(spacing: Theme.Spacing.xs) {
                                Text(tab.rawValue)
                                    .font(Theme.Typography.small)
                                    .foregroundColor(selectedTab == tab ? Theme.Colors.accent : Theme.Colors.textSecondary)
                                    .fontWeight(selectedTab == tab ? .semibold : .regular)
                                
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(selectedTab == tab ? Theme.Colors.accent : .clear)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.sm)
                        }
                    }
                }
                .background(Theme.Colors.background)
                .overlay(
                    Rectangle()
                        .frame(height: Theme.BorderWidth.thin)
                        .foregroundColor(Theme.Colors.border),
                    alignment: .bottom
                )
                
                // Content
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.md) {
                        ForEach(filteredRequests) { request in
                            VerificationRequestCard(request: request) {
                                selectedRequest = request
                                showingReviewSheet = true
                            }
                        }
                    }
                    .padding(Theme.Spacing.md)
                }
                .background(Theme.Colors.background)
            }
            .background(Theme.Colors.background)
            .navigationBarHidden(true)
            .sheet(item: $selectedRequest) { request in
                VerificationReviewSheet(request: request) {
                    selectedRequest = nil
                    showingReviewSheet = false
                }
            }
        }
    }
    
    private var filteredRequests: [VerificationRequest] {
        switch selectedTab {
        case .pending:
            return verificationManager.pendingRequests
        case .approved:
            return verificationManager.getApprovedVerifications()
        case .rejected:
            return verificationManager.getRejectedVerifications()
        }
    }
}

// MARK: - Verification Request Card

struct VerificationRequestCard: View {
    let request: VerificationRequest
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("Request #\(request.id.uuidString.prefix(8))")
                            .font(Theme.Typography.small)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .fontWeight(.semibold)
                        
                        Text("User: \(request.userId.uuidString.prefix(8))")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    VerificationStatusBadge(status: request.status)
                }
                
                Divider()
                    .background(Theme.Colors.border)
                
                HStack {
                    Label {
                        Text("Submitted")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    } icon: {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    
                    Text(request.submittedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Spacer()
                    
                    if request.status != .pending {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.Colors.textSecondary)
                    } else {
                        Text("TAP TO REVIEW")
                            .font(Theme.Typography.tiny)
                            .foregroundColor(Theme.Colors.accent)
                            .fontWeight(.semibold)
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
        .buttonStyle(.plain)
    }
}

// MARK: - Verification Status Badge

struct VerificationStatusBadge: View {
    let status: VerificationStatus
    
    var color: Color {
        switch status {
        case .pending: return .orange
        case .approved: return Theme.Colors.accent
        case .rejected: return .red
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(Theme.Typography.tiny)
            .foregroundColor(color)
            .fontWeight(.semibold)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(color.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .stroke(color, lineWidth: Theme.BorderWidth.thin)
            )
            .cornerRadius(Theme.CornerRadius.small)
    }
}

// MARK: - Preview

#Preview {
    AdminVerificationView()
}
