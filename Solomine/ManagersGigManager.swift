//
//  GigManager.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/4/26.
//

import Foundation
internal import Combine

/// Manages affiliate campaign contracts and real-time updates
@MainActor
class GigManager: ObservableObject {
    
    static let shared = GigManager()
    
    @Published var availableGigs: [GigListing] = []
    @Published var myPostedGigs: [GigListing] = []
    @Published var isLoading = false
    
    private var refreshTimer: Timer?
    
    private init() {
        loadMockGigs()
        startAutoRefresh()
    }
    
    // MARK: - Public Methods
    
    func loadGigs() {
        isLoading = true
        
        // In production, fetch from backend
        // For now, simulate network delay
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            loadMockGigs()
            isLoading = false
        }
    }
    
    func postGig(_ gig: GigListing) {
        availableGigs.insert(gig, at: 0)
        myPostedGigs.insert(gig, at: 0)
    }
    
    func removeGig(_ gigId: UUID) {
        availableGigs.removeAll { $0.id == gigId }
        myPostedGigs.removeAll { $0.id == gigId }
    }
    
    // MARK: - Auto Refresh
    
    private func startAutoRefresh() {
        // Simulate new gigs appearing every 15-30 seconds for lively marketplace
        refreshTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 15...30), repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.simulateNewGig()
            }
        }
    }
    
    private func simulateNewGig() {
        // Add a random new gig to make marketplace feel alive
        let newGig = generateRandomGig()
        availableGigs.insert(newGig, at: 0)
        
        // Keep only recent 50 gigs
        if availableGigs.count > 50 {
            availableGigs = Array(availableGigs.prefix(50))
        }
    }
    
    // MARK: - Mock Data
    
    private func loadMockGigs() {
        availableGigs = [
            GigListing(
                id: UUID(),
                hirerId: UUID(),
                hirerName: "NeonCart",
                hirerHandle: "@neoncart",
                freelancerId: nil,
                title: "US DTC Skincare - New Affiliate Program",
                description: "Launch campaign for our clean skincare line. We want creators and media buyers who can drive first-time customer purchases at scale.",
                requirements: ["Audience in US/CA", "Disclose sponsored links", "No trademark bidding"],
                budget: 6500,
                estimatedHours: 48,
                category: .influencers,
                urgency: .urgent,
                postedDate: Date().addingTimeInterval(-300), // 5 min ago
                applicants: 2,
                commissionType: .cpa,
                commissionValue: 58,
                cookieWindowDays: 45,
                targetRegion: "US / Canada"
            ),
            GigListing(
                id: UUID(),
                hirerId: UUID(),
                hirerName: "FlowLedger",
                hirerHandle: "@flowledger",
                freelancerId: nil,
                title: "B2B Finance SaaS - Rev Share Partners",
                description: "We are recruiting newsletter publishers and fintech educators to promote our annual plans. Strong EPC and predictable renewals.",
                requirements: ["B2B or finance audience", "Traffic quality review", "Monthly optimization call"],
                budget: 12000,
                estimatedHours: 72,
                category: .email,
                urgency: .normal,
                postedDate: Date().addingTimeInterval(-1800), // 30 min ago
                applicants: 5,
                commissionType: .revenueShare,
                commissionValue: 30,
                cookieWindowDays: 60,
                targetRegion: "US / UK / AU"
            ),
            GigListing(
                id: UUID(),
                hirerId: UUID(),
                hirerName: "AtlasTrips",
                hirerHandle: "@atlastrips",
                freelancerId: nil,
                title: "Travel Booking App - Hybrid Payout",
                description: "Looking for creators, SEO sites, and deal communities that can drive hotel app installs and completed stays.",
                requirements: ["Mobile-first audience", "No incent fraud", "Weekly reporting"],
                budget: 9800,
                estimatedHours: 24,
                category: .content,
                urgency: .normal,
                postedDate: Date().addingTimeInterval(-3600), // 1 hour ago
                applicants: 8,
                commissionType: .hybrid,
                commissionValue: 25,
                cookieWindowDays: 30,
                targetRegion: "Global"
            ),
            GigListing(
                id: UUID(),
                hirerId: UUID(),
                hirerName: "PulseProtein",
                hirerHandle: "@pulseprotein",
                freelancerId: nil,
                title: "Fitness Supplement Launch - Creator Push",
                description: "Need affiliate creators for TikTok, YouTube Shorts, and Instagram Reels. Product samples and custom coupon codes included.",
                requirements: ["Health/fitness niche", "UGC examples", "Brand safety compliant"],
                budget: 7200,
                estimatedHours: 36,
                category: .influencers,
                urgency: .urgent,
                postedDate: Date().addingTimeInterval(-7200), // 2 hours ago
                applicants: 12,
                commissionType: .cpa,
                commissionValue: 42,
                cookieWindowDays: 21,
                targetRegion: "US"
            ),
            GigListing(
                id: UUID(),
                hirerId: UUID(),
                hirerName: "VaultVPN",
                hirerHandle: "@vaultvpn",
                freelancerId: nil,
                title: "Cybersecurity App - SEO + Review Sites",
                description: "Scaling a VPN + password manager bundle with content affiliates. We provide pre-approved copy points and promo assets.",
                requirements: ["SEO traffic history", "Compliance-friendly content", "Monthly KPI check-in"],
                budget: 5300,
                estimatedHours: 72,
                category: .seo,
                urgency: .normal,
                postedDate: Date().addingTimeInterval(-10800), // 3 hours ago
                applicants: 15,
                commissionType: .revenueShare,
                commissionValue: 35,
                cookieWindowDays: 30,
                targetRegion: "EU / UK / US"
            ),
            GigListing(
                id: UUID(),
                hirerId: UUID(),
                hirerName: "ByteLearn",
                hirerHandle: "@bytelearn",
                freelancerId: nil,
                title: "EdTech Subscription - Student Ambassador Offer",
                description: "Campus and student-community affiliates wanted for exam prep subscription. Looking for authentic conversion-driven content.",
                requirements: ["Student audience", "Coupon placements", "No bot traffic"],
                budget: 2800,
                estimatedHours: 24,
                category: .communities,
                urgency: .urgent,
                postedDate: Date().addingTimeInterval(-14400), // 4 hours ago
                applicants: 3,
                commissionType: .cpa,
                commissionValue: 22,
                cookieWindowDays: 14,
                targetRegion: "US Colleges"
            ),
            GigListing(
                id: UUID(),
                hirerId: UUID(),
                hirerName: "DealDock",
                hirerHandle: "@dealdock",
                freelancerId: nil,
                title: "Coupon and Cashback Publishers Wanted",
                description: "Looking for coupon, cashback, and loyalty affiliates to promote marketplace deals. Dynamic codes and product feed included.",
                requirements: ["Coupon inventory", "Traffic source transparency", "Fraud filters enabled"],
                budget: 8600,
                estimatedHours: 36,
                category: .coupon,
                urgency: .normal,
                postedDate: Date().addingTimeInterval(-18000), // 5 hours ago
                applicants: 7,
                commissionType: .hybrid,
                commissionValue: 18,
                cookieWindowDays: 7,
                targetRegion: "Global"
            ),
            GigListing(
                id: UUID(),
                hirerId: UUID(),
                hirerName: "NovaHome",
                hirerHandle: "@novahome",
                freelancerId: nil,
                title: "Home Automation Brand - Paid Social Affiliates",
                description: "Need performance affiliates who run compliant paid social acquisition campaigns using tracked landing pages.",
                requirements: ["Meta/TikTok ads experience", "Pre-approval for creatives", "Daily spend pacing updates"],
                budget: 15000,
                estimatedHours: 48,
                category: .paidSocial,
                urgency: .normal,
                postedDate: Date().addingTimeInterval(-21600), // 6 hours ago
                applicants: 6,
                commissionType: .revenueShare,
                commissionValue: 20,
                cookieWindowDays: 30,
                targetRegion: "US / EU"
            )
        ]
    }
    
    private func generateRandomGig() -> GigListing {
        let titles = [
            "Creator Affiliates Needed for Product Launch",
            "Rev Share Offer for SaaS Newsletter Partners",
            "Coupon Publisher Contract - High EPC",
            "SEO Affiliate Program Expansion",
            "Paid Social Partner Opportunity",
            "Email Affiliate Blast Campaign",
            "B2B Referral Partnership Program",
            "Ambassador Program for New App",
            "Hybrid CPA + RevShare Contract",
            "Community Publisher Affiliate Invite"
        ]
        
        let names = ["Jordan", "Taylor", "Casey", "Morgan", "Riley", "Avery", "Quinn", "Sage"]
        let surnames = ["Smith", "Chen", "Kumar", "Garcia", "Lee", "Brown", "Wilson", "Martinez"]
        
        let name = "\(names.randomElement()!) \(surnames.randomElement()!)"
        let handle = "@\(name.lowercased().replacingOccurrences(of: " ", with: ""))"
        
        return GigListing(
            id: UUID(),
            hirerId: UUID(),
            hirerName: name,
            hirerHandle: handle,
            freelancerId: nil,
            title: titles.randomElement()!,
            description: "Looking for experienced affiliates to promote our product. Full contract terms are listed in requirements.",
            requirements: ["Verified traffic source", "Clear disclosure", "Weekly performance sync"],
            budget: Double([2500, 4000, 6500, 8000, 12000].randomElement()!),
            estimatedHours: [24, 36, 48, 72].randomElement()!,
            category: GigCategory.allCases.randomElement()!,
            urgency: [.urgent, .normal, .flexible].randomElement()!,
            postedDate: Date(),
            applicants: Int.random(in: 0...3),
            commissionType: AffiliateCommissionType.allCases.randomElement()!,
            commissionValue: Double([15, 20, 25, 30, 45, 60].randomElement()!),
            cookieWindowDays: [7, 14, 30, 45, 60].randomElement()!,
            targetRegion: ["US", "EU", "Global", "US / CA", "US / UK / AU"].randomElement()!
        )
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
}

// MARK: - Gig Listing Model

struct GigListing: Identifiable, Codable, Hashable {
    let id: UUID
    let hirerId: UUID
    let hirerName: String
    let hirerHandle: String
    var freelancerId: UUID?
    var title: String
    var description: String
    var requirements: [String]
    var budget: Double
    var estimatedHours: Int
    var category: GigCategory
    var urgency: GigUrgency
    var postedDate: Date
    var applicants: Int
    var commissionType: AffiliateCommissionType = .cpa
    var commissionValue: Double = 25
    var cookieWindowDays: Int = 30
    var targetRegion: String = "Global"
    
    var timeAgo: String {
        let interval = Date().timeIntervalSince(postedDate)
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)
        
        if minutes < 1 {
            return "JUST NOW"
        } else if minutes < 60 {
            return "\(minutes)M AGO"
        } else if hours < 24 {
            return "\(hours)H AGO"
        } else {
            return "\(days)D AGO"
        }
    }
    
    var commissionDisplay: String {
        switch commissionType {
        case .cpa:
            return "$\(Int(commissionValue)) / conversion"
        case .revenueShare:
            return "\(Int(commissionValue))% rev share"
        case .hybrid:
            return "$\(Int(commissionValue)) + rev share"
        }
    }
}

enum GigUrgency: String, Codable, Hashable, CaseIterable {
    case urgent = "HOT"
    case normal = "STANDARD"
    case flexible = "FLEXIBLE"
    
    var color: String {
        switch self {
        case .urgent: return "red"
        case .normal: return "accent"
        case .flexible: return "textSecondary"
        }
    }
}

enum AffiliateCommissionType: String, Codable, Hashable, CaseIterable {
    case cpa = "CPA"
    case revenueShare = "REV SHARE"
    case hybrid = "HYBRID"
}
