//
//  ModelsAdvertising.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import Foundation

// MARK: - Ad Campaign

/// Represents an advertising campaign purchased by a builder
struct AdCampaign: Identifiable, Codable {
    let id: UUID
    let advertiserId: UUID // Builder who purchased the ad
    let campaignType: AdCampaignType
    let placement: AdPlacement
    var budget: Double
    var spent: Double
    let startDate: Date
    let endDate: Date
    var status: AdCampaignStatus
    let targeting: AdTargeting?
    var metrics: AdMetrics
    let createdAt: Date
    var updatedAt: Date
    
    // Computed properties
    var isActive: Bool {
        status == .active &&
        Date() >= startDate &&
        Date() <= endDate &&
        spent < budget
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: endDate).day ?? 0
        return max(0, days)
    }
    
    var budgetRemaining: Double {
        max(0, budget - spent)
    }
    
    var progress: Double {
        guard budget > 0 else { return 0 }
        return min(1.0, spent / budget)
    }
    
    init(
        id: UUID = UUID(),
        advertiserId: UUID,
        campaignType: AdCampaignType,
        placement: AdPlacement,
        budget: Double,
        spent: Double = 0,
        startDate: Date,
        endDate: Date,
        status: AdCampaignStatus = .pending,
        targeting: AdTargeting? = nil,
        metrics: AdMetrics = AdMetrics(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.advertiserId = advertiserId
        self.campaignType = campaignType
        self.placement = placement
        self.budget = budget
        self.spent = spent
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.targeting = targeting
        self.metrics = metrics
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Campaign Types

enum AdCampaignType: String, Codable, CaseIterable {
    case profileBoost = "Profile Boost"
    case featuredListing = "Featured Listing"
    case agentBoost = "Agent Boost"
    case sponsoredSearch = "Sponsored Search"
    case bannerAd = "Banner Ad"
    
    var description: String {
        switch self {
        case .profileBoost:
            return "Boost your freelancer profile to appear at the top of search results"
        case .featuredListing:
            return "Feature your profile in the 'Featured Builders' section"
        case .agentBoost:
            return "Promote your AI agent to top of agent marketplace"
        case .sponsoredSearch:
            return "Appear at top of search results for specific keywords"
        case .bannerAd:
            return "Display banner ad in Explore section"
        }
    }
    
    var icon: String {
        switch self {
        case .profileBoost:
            return "arrow.up.circle.fill"
        case .featuredListing:
            return "star.fill"
        case .agentBoost:
            return "sparkles"
        case .sponsoredSearch:
            return "magnifyingglass.circle.fill"
        case .bannerAd:
            return "rectangle.stack.fill"
        }
    }
    
    var minimumBudget: Double {
        switch self {
        case .profileBoost:
            return 49.99 // 7 days
        case .featuredListing:
            return 99.99 // 7 days
        case .agentBoost:
            return 49.99 // 7 days
        case .sponsoredSearch:
            return 29.99 // Per keyword per week
        case .bannerAd:
            return 149.99 // Per week
        }
    }
}

// MARK: - Ad Placement

enum AdPlacement: String, Codable, CaseIterable {
    case exploreTop = "Explore - Top"
    case exploreFeatured = "Explore - Featured Section"
    case searchResults = "Search Results - Top"
    case agentMarketplaceTop = "Agent Marketplace - Top"
    case agentMarketplaceFeatured = "Agent Marketplace - Featured"
    case profilePageSidebar = "Profile Page - Sidebar"
    case contractsPageBanner = "Contracts Page - Banner"
    case homeFeed = "Home Feed"
    
    var costPerImpression: Double {
        switch self {
        case .exploreTop, .searchResults:
            return 0.05 // $0.05 per view
        case .exploreFeatured:
            return 0.03
        case .agentMarketplaceTop:
            return 0.04
        case .agentMarketplaceFeatured:
            return 0.03
        case .profilePageSidebar:
            return 0.02
        case .contractsPageBanner:
            return 0.03
        case .homeFeed:
            return 0.04
        }
    }
    
    var costPerClick: Double {
        switch self {
        case .exploreTop, .searchResults:
            return 0.50 // $0.50 per click
        case .exploreFeatured:
            return 0.30
        case .agentMarketplaceTop:
            return 0.40
        case .agentMarketplaceFeatured:
            return 0.30
        case .profilePageSidebar:
            return 0.20
        case .contractsPageBanner:
            return 0.30
        case .homeFeed:
            return 0.40
        }
    }
}

// MARK: - Campaign Status

enum AdCampaignStatus: String, Codable {
    case pending = "Pending Review"
    case active = "Active"
    case paused = "Paused"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case rejected = "Rejected"
}

// MARK: - Ad Targeting

struct AdTargeting: Codable {
    var targetSkills: [String]? // Show to people searching for these skills
    var targetLocation: String? // Geographic targeting (future)
    var targetBudget: BudgetRange? // Show to hirers with certain budgets
    var targetExperience: ExperienceLevel? // Target certain experience levels
    
    init(
        targetSkills: [String]? = nil,
        targetLocation: String? = nil,
        targetBudget: BudgetRange? = nil,
        targetExperience: ExperienceLevel? = nil
    ) {
        self.targetSkills = targetSkills
        self.targetLocation = targetLocation
        self.targetBudget = targetBudget
        self.targetExperience = targetExperience
    }
}

enum BudgetRange: String, Codable, CaseIterable {
    case under1k = "Under $1,000"
    case oneToFive = "$1,000 - $5,000"
    case fiveToTen = "$5,000 - $10,000"
    case tenToTwenty = "$10,000 - $20,000"
    case twentyPlus = "$20,000+"
}

enum ExperienceLevel: String, Codable, CaseIterable {
    case junior = "Junior"
    case mid = "Mid-level"
    case senior = "Senior"
    case expert = "Expert"
}

// MARK: - Ad Metrics

struct AdMetrics: Codable {
    var impressions: Int // How many times shown
    var clicks: Int // How many times clicked
    var conversions: Int // How many led to profile views
    var hires: Int // How many led to actual hires
    var revenue: Double // How much spent on this campaign
    
    var clickThroughRate: Double {
        guard impressions > 0 else { return 0 }
        return Double(clicks) / Double(impressions)
    }
    
    var conversionRate: Double {
        guard clicks > 0 else { return 0 }
        return Double(conversions) / Double(clicks)
    }
    
    var hireRate: Double {
        guard conversions > 0 else { return 0 }
        return Double(hires) / Double(conversions)
    }
    
    var costPerClick: Double {
        guard clicks > 0 else { return 0 }
        return revenue / Double(clicks)
    }
    
    var costPerHire: Double {
        guard hires > 0 else { return 0 }
        return revenue / Double(hires)
    }
    
    init(
        impressions: Int = 0,
        clicks: Int = 0,
        conversions: Int = 0,
        hires: Int = 0,
        revenue: Double = 0.0
    ) {
        self.impressions = impressions
        self.clicks = clicks
        self.conversions = conversions
        self.hires = hires
        self.revenue = revenue
    }
}

// MARK: - Boost Package

/// Pre-defined boost packages for easy purchase
struct BoostPackage: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let price: Double
    let duration: Int // Days
    let campaignType: AdCampaignType
    let placement: AdPlacement
    let estimatedImpressions: Int
    let featured: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        price: Double,
        duration: Int,
        campaignType: AdCampaignType,
        placement: AdPlacement,
        estimatedImpressions: Int,
        featured: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.duration = duration
        self.campaignType = campaignType
        self.placement = placement
        self.estimatedImpressions = estimatedImpressions
        self.featured = featured
    }
}

// MARK: - Ad Creative

/// The actual ad content/creative
struct AdCreative: Identifiable, Codable {
    let id: UUID
    let campaignId: UUID
    let headline: String
    let description: String
    let callToAction: String
    let imageURL: String?
    let profileId: UUID? // Link to freelancer profile
    let agentId: UUID? // Link to agent listing
    let createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        campaignId: UUID,
        headline: String,
        description: String,
        callToAction: String,
        imageURL: String? = nil,
        profileId: UUID? = nil,
        agentId: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.campaignId = campaignId
        self.headline = headline
        self.description = description
        self.callToAction = callToAction
        self.imageURL = imageURL
        self.profileId = profileId
        self.agentId = agentId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Ad Impression

/// Track individual ad impressions
struct AdImpression: Identifiable, Codable {
    let id: UUID
    let campaignId: UUID
    let userId: UUID? // User who saw the ad (if logged in)
    let placement: AdPlacement
    let timestamp: Date
    var clicked: Bool
    var converted: Bool // Did they view the profile?
    
    init(
        id: UUID = UUID(),
        campaignId: UUID,
        userId: UUID? = nil,
        placement: AdPlacement,
        timestamp: Date = Date(),
        clicked: Bool = false,
        converted: Bool = false
    ) {
        self.id = id
        self.campaignId = campaignId
        self.userId = userId
        self.placement = placement
        self.timestamp = timestamp
        self.clicked = clicked
        self.converted = converted
    }
}

// MARK: - Sample Data

extension BoostPackage {
    static let packages: [BoostPackage] = [
        // Profile Boost Packages
        BoostPackage(
            name: "Starter Boost",
            description: "7-day profile boost in search results",
            price: 49.99,
            duration: 7,
            campaignType: .profileBoost,
            placement: .searchResults,
            estimatedImpressions: 500
        ),
        BoostPackage(
            name: "Pro Boost",
            description: "14-day profile boost + featured section",
            price: 89.99,
            duration: 14,
            campaignType: .featuredListing,
            placement: .exploreFeatured,
            estimatedImpressions: 2000,
            featured: true
        ),
        BoostPackage(
            name: "Premium Boost",
            description: "30-day featured listing + search boost",
            price: 149.99,
            duration: 30,
            campaignType: .featuredListing,
            placement: .exploreFeatured,
            estimatedImpressions: 5000,
            featured: true
        ),
        
        // Agent Boost Packages
        BoostPackage(
            name: "Agent Starter",
            description: "7-day agent marketplace boost",
            price: 49.99,
            duration: 7,
            campaignType: .agentBoost,
            placement: .agentMarketplaceTop,
            estimatedImpressions: 300
        ),
        BoostPackage(
            name: "Agent Pro",
            description: "14-day featured agent listing",
            price: 89.99,
            duration: 14,
            campaignType: .agentBoost,
            placement: .agentMarketplaceFeatured,
            estimatedImpressions: 1500,
            featured: true
        ),
        
        // Sponsored Search
        BoostPackage(
            name: "Search Spotlight",
            description: "7-day sponsored search result",
            price: 29.99,
            duration: 7,
            campaignType: .sponsoredSearch,
            placement: .searchResults,
            estimatedImpressions: 200
        ),
        
        // Banner Ads
        BoostPackage(
            name: "Banner Week",
            description: "7-day banner ad on Explore page",
            price: 149.99,
            duration: 7,
            campaignType: .bannerAd,
            placement: .exploreTop,
            estimatedImpressions: 3000
        )
    ]
}

extension AdCampaign {
    static let sample = AdCampaign(
        advertiserId: UUID(),
        campaignType: .profileBoost,
        placement: .searchResults,
        budget: 49.99,
        spent: 23.45,
        startDate: Date().addingTimeInterval(-86400 * 3), // 3 days ago
        endDate: Date().addingTimeInterval(86400 * 4), // 4 days from now
        status: .active,
        metrics: AdMetrics(
            impressions: 427,
            clicks: 34,
            conversions: 12,
            hires: 2,
            revenue: 23.45
        )
    )
}
