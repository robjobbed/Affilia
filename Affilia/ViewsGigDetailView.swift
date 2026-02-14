//
//  GigDetailView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct GigDetailView: View {
    let gig: GigListing
    @State private var showingBookingSheet = false
    @Environment(\.dismiss) private var dismiss
    
    // Find affiliate profile for this listing
    var freelancer: FreelancerProfile? {
        MockData.shared.sampleFreelancers.first { $0.id == gig.freelancerId }
    }
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Header with back button
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack(spacing: Theme.Spacing.xs) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                Text("BACK")
                                    .font(Theme.Typography.caption)
                            }
                            .foregroundColor(Theme.Colors.accent)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.top, Theme.Spacing.sm)
                    
                    // Contract title and company
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text(gig.title)
                            .font(Theme.Typography.headingLarge)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        // Company info
                        HStack(spacing: Theme.Spacing.sm) {
                            ZStack {
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                    .fill(Theme.Colors.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                            .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                                    )
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(Theme.Colors.accent)
                            }
                            
                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                Text(gig.hirerName)
                                    .font(Theme.Typography.body)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                
                                HStack(spacing: Theme.Spacing.xs) {
                                    Image(systemName: "megaphone.fill")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    Text(gig.hirerHandle)
                                }
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.accent)
                            }
                            
                            Spacer()
                            
                            SkillTag(skill: gig.category.rawValue)
                        }
                    }
                    .padding(Theme.Spacing.md)
                    .terminalCard()
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    // Pricing and timing stats
                    HStack(spacing: Theme.Spacing.md) {
                        StatColumn(label: "MAX PAYOUT", value: "$\(Int(gig.budget))")
                        Divider()
                            .background(Theme.Colors.border)
                            .frame(height: 40)
                        StatColumn(label: "COMMISSION", value: gig.commissionDisplay)
                        Divider()
                            .background(Theme.Colors.border)
                            .frame(height: 40)
                        StatColumn(label: "POSTED", value: gig.postedDate.formatted(.relative(presentation: .named)))
                    }
                    .padding(Theme.Spacing.md)
                    .terminalCard()
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    // Description section
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        SectionHeader("Description")
                        
                        Text(gig.description)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .lineSpacing(6)
                            .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    // Categories section
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        SectionHeader("Categories")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Theme.Spacing.xs) {
                                CategoryTag(category: gig.category.rawValue)
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                        }
                    }
                    
                    // Contract terms section
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        SectionHeader("Contract Terms")
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            ForEach(gig.requirements, id: \.self) { deliverable in
                                HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                                    Text("•")
                                        .font(Theme.Typography.body)
                                        .foregroundColor(Theme.Colors.accent)
                                    Text(deliverable)
                                        .font(Theme.Typography.body)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                    Spacer()
                                }
                            }
                        }
                        .padding(Theme.Spacing.md)
                        .terminalCard()
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        SectionHeader("Tracking Details")
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            detailRow(label: "Commission Model", value: gig.commissionType.rawValue)
                            detailRow(label: "Cookie Window", value: "\(gig.cookieWindowDays) days")
                            detailRow(label: "Target Region", value: gig.targetRegion)
                            detailRow(label: "Company Response SLA", value: "\(gig.estimatedHours) hours")
                        }
                        .padding(Theme.Spacing.md)
                        .terminalCard()
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    // Action button
                    VStack(spacing: Theme.Spacing.sm) {
                        TerminalButton("APPLY TO THIS CONTRACT") {
                            showingBookingSheet = true
                        }
                        
                        Text("Top affiliates are accepted quickly on HOT contracts.")
                            .font(Theme.Typography.tiny)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.xl)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingBookingSheet) {
            BookingSheetView(gig: gig, freelancer: freelancer)
        }
    }
    
    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textPrimary)
        }
    }
}

// MARK: - Booking Sheet
struct BookingSheetView: View {
    let gig: GigListing
    let freelancer: FreelancerProfile?
    @Environment(\.dismiss) private var dismiss
    @State private var projectDetails = ""
    @State private var deadline: Date = Date().addingTimeInterval(7 * 24 * 60 * 60) // 7 days from now
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        // Summary
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            SectionHeader("Contract Summary")
                            
                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                Text(gig.title)
                                    .font(Theme.Typography.title)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                
                                Text("with \(gig.hirerName)")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                HStack {
                                    Text(gig.commissionDisplay)
                                        .font(Theme.Typography.title)
                                        .foregroundColor(Theme.Colors.accent)
                                    
                                    Spacer()
                                    
                                    Text("cookie: \(gig.cookieWindowDays)d")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                }
                                .padding(.top, Theme.Spacing.xs)
                            }
                            .padding(Theme.Spacing.md)
                            .terminalCard()
                        }
                        
                        // Affiliate application input
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            SectionHeader("Application Details")
                            
                            Text("Share your audience, channels, and promotion plan:")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            TextEditor(text: $projectDetails)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textPrimary)
                                .scrollContentBackground(.hidden)
                                .background(Theme.Colors.surface)
                                .frame(height: 150)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Theme.Colors.border, lineWidth: 1)
                                )
                            
                            if projectDetails.isEmpty {
                                Text("Include audience size, traffic sources, and expected volume...")
                                    .font(Theme.Typography.tiny)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .padding(.top, -140)
                                    .padding(.leading, Theme.Spacing.sm)
                                    .allowsHitTesting(false)
                            }
                        }
                        
                        // Launch estimate picker
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            SectionHeader("Planned Launch Date")
                            
                            DatePicker(
                                "Deadline",
                                selection: $deadline,
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .tint(Theme.Colors.accent)
                        }
                        
                        // Action buttons
                        VStack(spacing: Theme.Spacing.sm) {
                            TerminalButton("SEND APPLICATION") {
                                // Handle booking submission
                                dismiss()
                            }
                            
                            Button("Cancel") {
                                dismiss()
                            }
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                        }
                        .padding(.top, Theme.Spacing.md)
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .navigationTitle("Apply to Contract")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.accent)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    GigDetailView(gig: GigListing(
        id: UUID(),
        hirerId: UUID(),
        hirerName: "Preview User",
        hirerHandle: "@preview",
        freelancerId: nil,
        title: "Preview Gig",
        description: "This is a preview gig for testing the detail view.",
        requirements: ["SwiftUI", "Combine"],
        budget: 999,
        estimatedHours: 6,
        category: .content,
        urgency: .normal,
        postedDate: Date().addingTimeInterval(-600),
        applicants: 1
    ))
}
