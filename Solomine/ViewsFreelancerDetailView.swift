//
//  FreelancerDetailView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct FreelancerDetailView: View {
    let freelancer: FreelancerProfile
    @State private var isShortlisted = false
    @State private var showingHireSheet = false
    @State private var showingContractSheet = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Profile header
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        HStack(alignment: .top) {
                            AvatarView(displayName: freelancer.displayName, size: 60)
                            
                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                Text(freelancer.displayName)
                                    .font(Theme.Typography.headingLarge)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                
                                // X handle - primary identifier
                                Button(action: {
                                    // Open X profile
                                    if let url = URL(string: "https://x.com/\(freelancer.xUsername)") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack(spacing: Theme.Spacing.xs) {
                                        Image(systemName: "bird.fill")
                                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        Text(freelancer.handle)
                                    }
                                    .font(Theme.Typography.body)
                                    .foregroundColor(Theme.Colors.accent)
                                }
                                
                                // X credibility badges
                                XCredibilityBadge(freelancer: freelancer, showFollowers: true)
                                    .padding(.top, Theme.Spacing.xs)
                                
                                StatusTag(status: freelancer.availability)
                                    .padding(.top, Theme.Spacing.xs)
                            }
                            
                            Spacer()
                        }
                        .padding(Theme.Spacing.md)
                        .terminalCard()
                        
                        // Stats bar
                        HStack(spacing: Theme.Spacing.md) {
                            StatColumn(label: "PROJECTS", value: "\(freelancer.projectsCompleted)")
                            Divider()
                                .background(Theme.Colors.border)
                                .frame(height: 40)
                            StatColumn(label: "RATING", value: String(format: "%.1f", freelancer.averageRating))
                            Divider()
                                .background(Theme.Colors.border)
                                .frame(height: 40)
                            StatColumn(label: "MEMBER SINCE", value: freelancer.memberSince.formatted(.dateTime.year()))
                        }
                        .padding(Theme.Spacing.md)
                        .terminalCard()
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    // Bio section
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        SectionHeader("Bio")
                        
                        Text(freelancer.bio)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    // Skills section
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        SectionHeader("Skills")
                        
                        FlowLayout(spacing: Theme.Spacing.xs) {
                            ForEach(freelancer.skills, id: \.self) { skill in
                                SkillTag(skill: skill)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    // Pricing section
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        SectionHeader("Pricing")
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            if let hourly = freelancer.hourlyRate {
                                HStack {
                                    Text("HOURLY RATE:")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    Text("$\(Int(hourly))/hr")
                                        .font(Theme.Typography.body)
                                        .foregroundColor(Theme.Colors.accent)
                                }
                            }
                            
                            if let project = freelancer.projectBasedPricing {
                                HStack {
                                    Text("PROJECT-BASED:")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    Text("$\(Int(project))")
                                        .font(Theme.Typography.body)
                                        .foregroundColor(Theme.Colors.accent)
                                }
                            }
                        }
                        .padding(Theme.Spacing.md)
                        .terminalCard()
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    // Portfolio section
                    if !freelancer.portfolioProjects.isEmpty {
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            SectionHeader("Portfolio")
                            
                            VStack(spacing: Theme.Spacing.md) {
                                ForEach(freelancer.portfolioProjects) { project in
                                    PortfolioProjectCard(project: project)
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                        }
                    }
                    
                    // X Content section - vibe coding posts
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        SectionHeader("X Activity", icon: "bird.fill")
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("See \(freelancer.handle)'s vibe coding content, dev posts, and project updates on X.")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .lineSpacing(4)
                            
                            NavigationLink(destination: XContentView(freelancer: freelancer)) {
                                HStack {
                                    Image(systemName: "bird.fill")
                                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    Text("VIEW X POSTS")
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                                }
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.accent)
                                .padding(.vertical, Theme.Spacing.sm)
                                .padding(.horizontal, Theme.Spacing.md)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                        .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                                )
                                .cornerRadius(Theme.CornerRadius.small)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(Theme.Spacing.md)
                        .terminalCard()
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    // Action buttons
                    VStack(spacing: Theme.Spacing.sm) {
                        TerminalButton("CREATE CONTRACT") {
                            showingContractSheet = true
                        }
                        
                        Button(action: { isShortlisted.toggle() }) {
                            HStack {
                                Image(systemName: isShortlisted ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                                Text(isShortlisted ? "SHORTLISTED" : "ADD TO SHORTLIST")
                            }
                            .font(Theme.Typography.body)
                            .foregroundColor(isShortlisted ? Theme.Colors.background : Theme.Colors.accentSecondary)
                            .padding(.horizontal, Theme.Spacing.md)
                            .padding(.vertical, Theme.Spacing.sm)
                            .frame(maxWidth: .infinity)
                            .background(isShortlisted ? Theme.Colors.accentSecondary : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                    .stroke(Theme.Colors.accentSecondary, lineWidth: Theme.BorderWidth.thin)
                            )
                            .cornerRadius(Theme.CornerRadius.medium)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.top, Theme.Spacing.md)
                    
                    Spacer(minLength: Theme.Spacing.xl)
                }
                .padding(.vertical, Theme.Spacing.md)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(freelancer.handle.uppercased())
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.accent)
            }
        }
        .toolbarBackground(Theme.Colors.surface, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showingContractSheet) {
            CreateContractView(freelancer: freelancer) { contract in
                // Handle contract creation
                print("Contract created: \(contract.projectTitle)")
            }
        }
    }
}

struct StatColumn: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text(value)
                .font(Theme.Typography.title)
                .foregroundColor(Theme.Colors.accent)
            Text(label)
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PortfolioProjectCard: View {
    let project: PortfolioProject
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(project.name)
                .font(Theme.Typography.title)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text(project.description)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(4)
            
            HStack(spacing: Theme.Spacing.sm) {
                if let github = project.githubURL, let url = URL(string: github) {
                    Button(action: {
                        UIApplication.shared.open(url)
                    }) {
                        LinkButton(title: "GITHUB", icon: "chevron.left.forwardslash.chevron.right")
                    }
                }
                
                if let projectURL = project.projectURL, let url = URL(string: projectURL) {
                    Button(action: {
                        UIApplication.shared.open(url)
                    }) {
                        LinkButton(title: "LIVE", icon: "link")
                    }
                }
            }
        }
        .padding(Theme.Spacing.md)
        .terminalCard()
    }
}

struct LinkButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .regular, design: .monospaced))
            Text(title)
                .font(Theme.Typography.tiny)
        }
        .foregroundColor(Theme.Colors.accent)
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xs)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
        )
        .cornerRadius(Theme.CornerRadius.small)
    }
}

#Preview {
    NavigationStack {
        FreelancerDetailView(freelancer: MockData.shared.sampleFreelancers[0])
    }
}
