//
//  MockData.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import Foundation

class MockData {
    
    static let shared = MockData()
    
    // Sample freelancer IDs for reference
    let freelancerId1 = UUID()
    let freelancerId2 = UUID()
    let freelancerId3 = UUID()
    let freelancerId4 = UUID()
    let freelancerId5 = UUID()
    let freelancerId6 = UUID()
    
    // Current user ID
    let currentUserId = UUID()
    
    lazy var sampleFreelancers: [FreelancerProfile] = [
        FreelancerProfile(
            id: freelancerId1,
            xUsername: "robcodes",
            displayName: "Rob Behbahani",
            bio: "Affiliate growth operator focused on DTC brands. I scale creator and email funnels with clean tracking.",
            skills: ["Creator Ops", "Email", "Attribution", "Offer Testing", "CRO"],
            portfolioProjects: [
                PortfolioProject(
                    name: "NeuralChat",
                    description: "Real-time AI chat app with custom ML models",
                    projectURL: "https://neuralchat.app",
                    githubURL: "https://github.com/robcodes/neuralchat"
                ),
                PortfolioProject(
                    name: "SwiftSnap",
                    description: "Lightning-fast photo editor for iOS with advanced filters",
                    projectURL: "https://apps.apple.com/swiftsnap"
                )
            ],
            hourlyRate: 150,
            availability: .openToWork,
            projectsCompleted: 47,
            averageRating: 4.9,
            memberSince: Date().addingTimeInterval(-86400 * 365),
            xFollowers: 5420,
            xFollowing: 892,
            xVerified: false
        ),
        FreelancerProfile(
            id: freelancerId2,
            xUsername: "cybervoid",
            displayName: "Alex Chen",
            bio: "Performance affiliate specializing in paid social and compliance-safe ad systems.",
            skills: ["Paid Social", "Meta Ads", "TikTok Ads", "Funnel QA", "Compliance"],
            portfolioProjects: [
                PortfolioProject(
                    name: "VaultAPI",
                    description: "Encrypted data storage API with military-grade security",
                    githubURL: "https://github.com/cybervoid/vaultapi"
                )
            ],
            hourlyRate: 180,
            availability: .selective,
            projectsCompleted: 62,
            averageRating: 5.0,
            memberSince: Date().addingTimeInterval(-86400 * 500),
            xFollowers: 12300,
            xFollowing: 445,
            xVerified: true
        ),
        FreelancerProfile(
            id: freelancerId3,
            xUsername: "pixelwitch",
            displayName: "Maya Rodriguez",
            bio: "UGC creator and influencer affiliate focused on beauty, wellness, and lifestyle conversion content.",
            skills: ["UGC", "Influencer", "Reels", "TikTok", "Story Ads"],
            portfolioProjects: [
                PortfolioProject(
                    name: "LunarUI",
                    description: "Open-source SwiftUI component library with 100+ elements",
                    githubURL: "https://github.com/pixelwitch/lunarui"
                ),
                PortfolioProject(
                    name: "FlowState",
                    description: "Productivity app with award-winning interface design",
                    projectURL: "https://flowstate.app"
                )
            ],
            projectBasedPricing: 5000,
            availability: .booked,
            projectsCompleted: 33,
            averageRating: 4.8,
            memberSince: Date().addingTimeInterval(-86400 * 200),
            xFollowers: 8750,
            xFollowing: 1205,
            xVerified: false
        ),
        FreelancerProfile(
            id: freelancerId4,
            xUsername: "datadruid",
            displayName: "Sam Okafor",
            bio: "SEO affiliate with high-intent review pages and evergreen search traffic.",
            skills: ["SEO", "Content Sites", "Review Pages", "Keyword Research", "Backlink Ops"],
            portfolioProjects: [
                PortfolioProject(
                    name: "VisionCore",
                    description: "Real-time object detection SDK for mobile apps",
                    githubURL: "https://github.com/datadruid/visioncore"
                )
            ],
            hourlyRate: 200,
            availability: .openToWork,
            projectsCompleted: 28,
            averageRating: 4.9,
            memberSince: Date().addingTimeInterval(-86400 * 450),
            xFollowers: 15800,
            xFollowing: 623,
            xVerified: false
        ),
        FreelancerProfile(
            id: freelancerId5,
            xUsername: "rustlord",
            displayName: "Jordan Kim",
            bio: "Deal and coupon affiliate. I drive incremental checkout conversions with timed promotions.",
            skills: ["Coupon", "Cashback", "Deal Feeds", "Loyalty", "Promo Distribution"],
            portfolioProjects: [
                PortfolioProject(
                    name: "BlazeFast",
                    description: "High-performance web server written in Rust, 10x faster than alternatives",
                    githubURL: "https://github.com/rustlord/blazefast"
                )
            ],
            hourlyRate: 175,
            availability: .selective,
            projectsCompleted: 19,
            averageRating: 5.0,
            memberSince: Date().addingTimeInterval(-86400 * 150),
            xFollowers: 9230,
            xFollowing: 734,
            xVerified: false
        ),
        FreelancerProfile(
            id: freelancerId6,
            xUsername: "apiwhisperer",
            displayName: "Priya Sharma",
            bio: "B2B affiliate partner for SaaS and fintech. Strong newsletter placements and webinar funnels.",
            skills: ["B2B Partnerships", "Newsletters", "Webinars", "Lead Gen", "Rev Share"],
            portfolioProjects: [
                PortfolioProject(
                    name: "GraphQL Studio",
                    description: "Visual GraphQL schema builder and testing suite",
                    projectURL: "https://graphqlstudio.dev",
                    githubURL: "https://github.com/apiwhisperer/graphql-studio"
                )
            ],
            hourlyRate: 165,
            availability: .openToWork,
            projectsCompleted: 41,
            averageRating: 4.7,
            memberSince: Date().addingTimeInterval(-86400 * 300),
            xFollowers: 6540,
            xFollowing: 892,
            xVerified: false
        )
    ]
    
    lazy var sampleGigs: [Gig] = [
        Gig(
            freelancerId: freelancerId1,
            title: "Build Custom SwiftUI Dashboard",
            description: "I'll create a fully custom SwiftUI dashboard with real-time data visualization, smooth animations, and a design that matches your brand.",
            deliverables: ["Complete SwiftUI source code", "Custom components library", "Documentation", "2 rounds of revisions"],
            turnaroundDays: 7,
            price: 2500,
            categories: [.content, .influencers]
        ),
        Gig(
            freelancerId: freelancerId1,
            title: "AI Integration Consulting",
            description: "1-hour consultation on integrating AI/ML models into your iOS app. I'll review your architecture and provide actionable recommendations.",
            deliverables: ["1-hour video call", "Technical writeup", "Code samples"],
            turnaroundDays: 3,
            price: 300,
            categories: [.paidSocial]
        ),
        Gig(
            freelancerId: freelancerId2,
            title: "Security Audit for Web Apps",
            description: "Comprehensive security audit of your web application. I'll find vulnerabilities before the bad guys do.",
            deliverables: ["Detailed vulnerability report", "Remediation guide", "Follow-up consultation"],
            turnaroundDays: 5,
            price: 3500,
            categories: [.seo, .email]
        ),
        Gig(
            freelancerId: freelancerId3,
            title: "SwiftUI Design System",
            description: "Complete design system built in SwiftUI with reusable components, color schemes, typography, and animation patterns.",
            deliverables: ["Figma design files", "SwiftUI component library", "Usage documentation", "Example app"],
            turnaroundDays: 14,
            price: 5000,
            categories: [.influencers, .content]
        ),
        Gig(
            freelancerId: freelancerId4,
            title: "Custom ML Model Training",
            description: "I'll train a custom machine learning model for your specific use case. Computer vision, NLP, or other domains.",
            deliverables: ["Trained model", "Python training scripts", "Integration guide", "Performance metrics"],
            turnaroundDays: 10,
            price: 4000,
            categories: [.paidSocial]
        ),
        Gig(
            freelancerId: freelancerId5,
            title: "Performance Optimization",
            description: "I'll analyze and optimize your codebase for maximum performance. Focus on critical paths and bottlenecks.",
            deliverables: ["Performance audit report", "Optimized code", "Benchmarks"],
            turnaroundDays: 7,
            price: 3000,
            categories: [.communities, .other]
        ),
        Gig(
            freelancerId: freelancerId6,
            title: "GraphQL API Development",
            description: "Full-featured GraphQL API with authentication, authorization, caching, and real-time subscriptions.",
            deliverables: ["GraphQL schema", "Backend implementation", "API documentation", "Testing suite"],
            turnaroundDays: 14,
            price: 6000,
            categories: [.email, .seo]
        )
    ]
    
    lazy var sampleConversations: [Conversation] = [
        Conversation(
            participantIds: [currentUserId, freelancerId1],
            participantNames: ["You", "robcodes"],
            lastMessage: ChatMessage(
                senderId: freelancerId1,
                conversationId: UUID(),
                content: "Sure, I can have the prototype ready by Friday. Let me send over the quote.",
                timestamp: Date().addingTimeInterval(-3600),
                isRead: false
            ),
            unreadCount: 1
        ),
        Conversation(
            participantIds: [currentUserId, freelancerId3],
            participantNames: ["You", "pixelwitch"],
            lastMessage: ChatMessage(
                senderId: currentUserId,
                conversationId: UUID(),
                content: "Thanks for the mockups! They look amazing. When can we start implementation?",
                timestamp: Date().addingTimeInterval(-86400),
                isRead: true
            ),
            unreadCount: 0
        ),
        Conversation(
            participantIds: [currentUserId, freelancerId4],
            participantNames: ["You", "datadruid"],
            lastMessage: ChatMessage(
                senderId: freelancerId4,
                conversationId: UUID(),
                content: "Model training is complete. Accuracy is at 94.3%. Sending over the deployment guide now.",
                timestamp: Date().addingTimeInterval(-7200),
                isRead: false
            ),
            unreadCount: 2
        )
    ]
    
    lazy var currentUser: User = User(
        id: currentUserId,
        email: "you@solomine.dev",
        role: .hirer,
        shortlistedFreelancers: [freelancerId1, freelancerId3]
    )
}
