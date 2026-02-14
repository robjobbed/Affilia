//
//  GigDetailView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/4/26.
//

import SwiftUI

/// Detailed view of a gig with application interface
struct GigApplicationDetailView: View {
    let gig: GigListing
    @Environment(\.dismiss) private var dismiss
    
    @State private var proposedPrice: String = ""
    @State private var proposedHours: String = ""
    @State private var coverLetter: String = ""
    @State private var showingApplicationConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        // Header
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            HStack {
                                UrgencyBadge(urgency: gig.urgency)
                                
                                Spacer()
                                
                                HStack(spacing: Theme.Spacing.xs) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                                    Text(gig.timeAgo)
                                        .font(Theme.Typography.tiny)
                                }
                                .foregroundColor(Theme.Colors.textSecondary)
                            }
                            
                            Text(gig.title)
                                .font(Theme.Typography.h2)
                                .foregroundColor(Theme.Colors.textPrimary)
                                .fontWeight(.bold)
                            
                            HStack(spacing: Theme.Spacing.xs) {
                                Text("Posted by")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                Text(gig.hirerHandle)
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.accent)
                            }
                        }
                        
                        Divider()
                            .background(Theme.Colors.border)
                        
                        // Budget and Time
                        HStack(spacing: Theme.Spacing.lg) {
                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                Text("BUDGET")
                                    .font(Theme.Typography.tiny)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                Text("$\(Int(gig.budget))")
                                    .font(Theme.Typography.h2)
                                    .foregroundColor(Theme.Colors.accent)
                                    .fontWeight(.bold)
                            }
                            
                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                Text("EST. TIME")
                                    .font(Theme.Typography.tiny)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                Text("\(gig.estimatedHours) hours")
                                    .font(Theme.Typography.title)
                                    .foregroundColor(Theme.Colors.textPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                Text("APPLICANTS")
                                    .font(Theme.Typography.tiny)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                Text("\(gig.applicants)")
                                    .font(Theme.Typography.title)
                                    .foregroundColor(Theme.Colors.textPrimary)
                            }
                        }
                        .padding(Theme.Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.Colors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
                        )
                        .cornerRadius(Theme.CornerRadius.medium)
                        
                        // Category
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("CATEGORY")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            SkillTag(skill: gig.category.rawValue)
                        }
                        
                        Divider()
                            .background(Theme.Colors.border)
                        
                        // Description
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("DESCRIPTION")
                                .font(Theme.Typography.title)
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Text(gig.description)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .lineSpacing(4)
                        }
                        
                        // Requirements
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("REQUIREMENTS")
                                .font(Theme.Typography.title)
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                ForEach(gig.requirements, id: \.self) { requirement in
                                    HStack(alignment: .top, spacing: Theme.Spacing.xs) {
                                        Text("•")
                                            .font(Theme.Typography.body)
                                            .foregroundColor(Theme.Colors.accent)
                                        
                                        Text(requirement)
                                            .font(Theme.Typography.body)
                                            .foregroundColor(Theme.Colors.textSecondary)
                                    }
                                }
                            }
                            .padding(Theme.Spacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.Colors.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                    .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
                            )
                            .cornerRadius(Theme.CornerRadius.medium)
                        }
                        
                        Divider()
                            .background(Theme.Colors.border)
                        
                        // Application Form
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Text("YOUR APPLICATION")
                                .font(Theme.Typography.title)
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Text("Stand out by proposing your own pricing and timeline")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            HStack(spacing: Theme.Spacing.md) {
                                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                    Text("YOUR PRICE")
                                        .font(Theme.Typography.tiny)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    
                                    HStack {
                                        Text("$")
                                            .font(Theme.Typography.body)
                                            .foregroundColor(Theme.Colors.accent)
                                        
                                        TextField("", text: $proposedPrice, prompt: Text("e.g., \(Int(gig.budget))").foregroundColor(Theme.Colors.textSecondary))
                                            .font(Theme.Typography.body)
                                            .foregroundColor(Theme.Colors.textPrimary)
                                            .keyboardType(.numberPad)
                                    }
                                    .padding(Theme.Spacing.sm)
                                    .background(Theme.Colors.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                            .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
                                    )
                                    .cornerRadius(Theme.CornerRadius.small)
                                }
                                
                                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                    Text("YOUR TIME")
                                        .font(Theme.Typography.tiny)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    
                                    HStack {
                                        TextField("", text: $proposedHours, prompt: Text("\(gig.estimatedHours)").foregroundColor(Theme.Colors.textSecondary))
                                            .font(Theme.Typography.body)
                                            .foregroundColor(Theme.Colors.textPrimary)
                                            .keyboardType(.numberPad)
                                        
                                        Text("hrs")
                                            .font(Theme.Typography.body)
                                            .foregroundColor(Theme.Colors.textSecondary)
                                    }
                                    .padding(Theme.Spacing.sm)
                                    .background(Theme.Colors.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                            .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
                                    )
                                    .cornerRadius(Theme.CornerRadius.small)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                Text("COVER LETTER")
                                    .font(Theme.Typography.tiny)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                TextEditor(text: $coverLetter)
                                    .font(Theme.Typography.body)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                    .frame(minHeight: 120)
                                    .padding(Theme.Spacing.sm)
                                    .background(Theme.Colors.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                            .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
                                    )
                                    .cornerRadius(Theme.CornerRadius.small)
                                
                                if coverLetter.isEmpty {
                                    Text("> Explain why you're the right fit_")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                        .padding(.horizontal, Theme.Spacing.sm)
                                        .offset(y: -100)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                        
                        // Apply Button
                        Button {
                            showingApplicationConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("SUBMIT APPLICATION")
                            }
                            .font(Theme.Typography.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.accent)
                            .cornerRadius(Theme.CornerRadius.medium)
                        }
                        .disabled(coverLetter.isEmpty)
                        .opacity(coverLetter.isEmpty ? 0.5 : 1.0)
                        
                        Spacer(minLength: Theme.Spacing.xl)
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.accent)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Share gig
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.accent)
                    }
                }
            }
            .alert("Application Submitted!", isPresented: $showingApplicationConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your application has been sent to \(gig.hirerHandle). They'll review it and get back to you soon!")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    GigApplicationDetailView(
        gig: GigListing(
            id: UUID(),
            hirerId: UUID(),
            hirerName: "Sarah Chen",
            hirerHandle: "@sarahbuilds",
            freelancerId: nil,
            title: "SwiftUI App Dashboard - 3 Screens",
            description: "Need a clean, modern dashboard for fitness tracking app. Must have charts, user profile, and settings. Looking for terminal/cyberpunk aesthetic.",
            requirements: ["SwiftUI experience", "Charts framework", "iOS 17+"],
            budget: 1200,
            estimatedHours: 8,
            category: .content,
            urgency: .urgent,
            postedDate: Date().addingTimeInterval(-300),
            applicants: 2
        )
    )
}
