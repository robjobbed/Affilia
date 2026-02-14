//
//  XContentView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

/// Shows X posts from a freelancer - their vibe coding content
struct XContentView: View {
    let freelancer: FreelancerProfile
    @State private var posts: [XPost] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    // Header
                    HStack {
                        Image(systemName: "bird.fill")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(Theme.Colors.accent)
                        
                        Text("\(freelancer.handle.uppercased()) ON X")
                            .font(Theme.Typography.heading)
                            .foregroundColor(Theme.Colors.accent)
                        
                        Spacer()
                        
                        Button(action: {
                            if let url = URL(string: "https://x.com/\(freelancer.xUsername)") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(Theme.Colors.accent)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.top, Theme.Spacing.md)
                    
                    // X stats
                    HStack(spacing: Theme.Spacing.lg) {
                        XStatItem(label: "FOLLOWERS", value: "\(formatNumber(freelancer.xFollowers))")
                        XStatItem(label: "FOLLOWING", value: "\(formatNumber(freelancer.xFollowing))")
                        if freelancer.xVerified {
                            HStack(spacing: Theme.Spacing.xs) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 12, weight: .bold))
                                Text("VERIFIED")
                                    .font(Theme.Typography.tiny)
                            }
                            .foregroundColor(Theme.Colors.accent)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    Divider()
                        .background(Theme.Colors.border)
                        .padding(.horizontal, Theme.Spacing.md)
                    
                    // Posts section
                    if isLoading {
                        LoadingIndicator()
                            .padding(.vertical, Theme.Spacing.xxl)
                    } else if posts.isEmpty {
                        VStack(spacing: Theme.Spacing.md) {
                            Text("> no posts loaded yet")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            Text("In production, this would show recent X posts about their dev work, projects, and vibe coding content.")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Theme.Spacing.xl)
                            
                            BlinkingCursor()
                        }
                        .padding(.vertical, Theme.Spacing.xxl)
                    } else {
                        LazyVStack(spacing: Theme.Spacing.md) {
                            ForEach(posts) { post in
                                XPostCard(post: post)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    Spacer(minLength: Theme.Spacing.xl)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("X CONTENT")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.accent)
            }
        }
        .toolbarBackground(Theme.Colors.surface, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            // Simulate loading posts
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isLoading = false
                // In production: Fetch real X posts via API
                posts = []
            }
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1000000 {
            return String(format: "%.1fM", Double(number) / 1000000.0)
        } else if number >= 1000 {
            return String(format: "%.1fK", Double(number) / 1000.0)
        } else {
            return "\(number)"
        }
    }
}

struct XStatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(value)
                .font(Theme.Typography.title)
                .foregroundColor(Theme.Colors.accent)
            Text(label)
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
}

struct XPostCard: View {
    let post: XPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(post.content)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textPrimary)
                .lineSpacing(4)
            
            HStack(spacing: Theme.Spacing.md) {
                XPostStat(icon: "heart", count: post.likes)
                XPostStat(icon: "arrow.2.squarepath", count: post.retweets)
                XPostStat(icon: "bubble.left", count: post.replies)
                
                Spacer()
                
                Text(timeAgoString(from: post.createdAt))
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.top, Theme.Spacing.xs)
        }
        .padding(Theme.Spacing.md)
        .terminalCard()
    }
    
    private func timeAgoString(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        
        if seconds < 60 {
            return "just now"
        } else if seconds < 3600 {
            return "\(seconds / 60)m"
        } else if seconds < 86400 {
            return "\(seconds / 3600)h"
        } else {
            return "\(seconds / 86400)d"
        }
    }
}

struct XPostStat: View {
    let icon: String
    let count: Int
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .regular, design: .monospaced))
            Text("\(count)")
                .font(Theme.Typography.tiny)
        }
        .foregroundColor(Theme.Colors.textSecondary)
    }
}

// Model for X posts
struct XPost: Identifiable, Codable {
    let id: String
    let content: String
    let createdAt: Date
    let likes: Int
    let retweets: Int
    let replies: Int
}

#Preview {
    NavigationStack {
        XContentView(freelancer: MockData.shared.sampleFreelancers[0])
    }
}
