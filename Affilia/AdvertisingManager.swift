//
//  AdvertisingManager.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import Foundation
import SwiftUI
internal import Combine

/// Manages advertising campaigns and boosts for builders
@MainActor
class AdvertisingManager: ObservableObject {
    static let shared = AdvertisingManager()
    
    @Published var myCampaigns: [AdCampaign] = []
    @Published var activeCampaigns: [AdCampaign] = []
    @Published var totalRevenue: Double = 0.0
    @Published var totalSpent: Double = 0.0
    
    private init() {
        loadCampaigns()
    }
    
    // MARK: - Campaign Management
    
    func loadCampaigns() {
        // In production: Fetch from API
        myCampaigns = []
        activeCampaigns = []
        calculateRevenue()
    }
    
    func createCampaign(
        campaignType: AdCampaignType,
        placement: AdPlacement,
        budget: Double,
        duration: Int,
        targeting: AdTargeting? = nil
    ) async throws -> AdCampaign {
        // Validate budget
        guard budget >= campaignType.minimumBudget else {
            throw AdError.budgetTooLow(minimum: campaignType.minimumBudget)
        }
        
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: duration, to: startDate)!
        
        let campaign = AdCampaign(
            advertiserId: MockData.shared.currentUserId,
            campaignType: campaignType,
            placement: placement,
            budget: budget,
            startDate: startDate,
            endDate: endDate,
            status: .pending,
            targeting: targeting
        )
        
        // In production: Submit to backend for review
        myCampaigns.append(campaign)
        totalSpent += budget
        
        return campaign
    }
    
    func purchaseBoostPackage(_ package: BoostPackage) async throws -> AdCampaign {
        // Process payment
        try await processPayment(amount: package.price, description: "Boost: \(package.name)")
        
        // Create campaign from package
        let campaign = try await createCampaign(
            campaignType: package.campaignType,
            placement: package.placement,
            budget: package.price,
            duration: package.duration
        )
        
        return campaign
    }
    
    func pauseCampaign(_ campaignId: UUID) {
        if let index = myCampaigns.firstIndex(where: { $0.id == campaignId }) {
            myCampaigns[index].status = .paused
            myCampaigns[index].updatedAt = Date()
        }
    }
    
    func resumeCampaign(_ campaignId: UUID) {
        if let index = myCampaigns.firstIndex(where: { $0.id == campaignId }) {
            myCampaigns[index].status = .active
            myCampaigns[index].updatedAt = Date()
        }
    }
    
    func cancelCampaign(_ campaignId: UUID) async throws {
        if let index = myCampaigns.firstIndex(where: { $0.id == campaignId }) {
            let campaign = myCampaigns[index]
            
            // Calculate refund (if applicable)
            let refund = campaign.budgetRemaining
            
            myCampaigns[index].status = .cancelled
            myCampaigns[index].updatedAt = Date()
            
            // In production: Process refund if any budget remaining
            if refund > 0 {
                // Refund unused budget
                totalSpent -= refund
            }
        }
    }
    
    // MARK: - Metrics & Analytics
    
    func trackImpression(campaignId: UUID, userId: UUID?, placement: AdPlacement) {
        if let index = myCampaigns.firstIndex(where: { $0.id == campaignId }) {
            myCampaigns[index].metrics.impressions += 1
            
            // Charge for impression (CPM model)
            let cost = placement.costPerImpression
            myCampaigns[index].spent += cost
            
            // In production: Send to analytics backend
            logAnalytics(event: "ad_impression", campaignId: campaignId)
        }
    }
    
    func trackClick(campaignId: UUID, userId: UUID?) {
        if let index = myCampaigns.firstIndex(where: { $0.id == campaignId }) {
            myCampaigns[index].metrics.clicks += 1
            
            // Charge for click (CPC model)
            let campaign = myCampaigns[index]
            let cost = campaign.placement.costPerClick
            myCampaigns[index].spent += cost
            
            logAnalytics(event: "ad_click", campaignId: campaignId)
        }
    }
    
    func trackConversion(campaignId: UUID, userId: UUID?) {
        if let index = myCampaigns.firstIndex(where: { $0.id == campaignId }) {
            myCampaigns[index].metrics.conversions += 1
            logAnalytics(event: "ad_conversion", campaignId: campaignId)
        }
    }
    
    func trackHire(campaignId: UUID, contractValue: Double) {
        if let index = myCampaigns.firstIndex(where: { $0.id == campaignId }) {
            myCampaigns[index].metrics.hires += 1
            logAnalytics(event: "ad_hire", campaignId: campaignId, value: contractValue)
        }
    }
    
    // MARK: - Revenue Calculation
    
    private func calculateRevenue() {
        totalRevenue = myCampaigns.reduce(0) { $0 + $1.spent }
        totalSpent = myCampaigns.reduce(0) { $0 + $1.budget }
    }
    
    // MARK: - Ad Delivery
    
    /// Get active campaigns for a specific placement
    func getActiveCampaigns(for placement: AdPlacement, limit: Int = 5) -> [AdCampaign] {
        return activeCampaigns
            .filter { campaign in
                campaign.isActive &&
                campaign.placement == placement
            }
            .sorted { campaign1, campaign2 in
                // Prioritize higher-budget campaigns
                campaign1.budget > campaign2.budget
            }
            .prefix(limit)
            .map { $0 }
    }
    
    /// Get boosted profiles (builders who paid for visibility)
    func getBoostedProfiles(limit: Int = 3) -> [UUID] {
        return activeCampaigns
            .filter { campaign in
                campaign.isActive &&
                (campaign.campaignType == .profileBoost || campaign.campaignType == .featuredListing)
            }
            .sorted { $0.budget > $1.budget }
            .prefix(limit)
            .map { $0.advertiserId }
    }
    
    /// Get boosted agents
    func getBoostedAgents(limit: Int = 3) -> [UUID] {
        return activeCampaigns
            .filter { campaign in
                campaign.isActive &&
                campaign.campaignType == .agentBoost
            }
            .sorted { $0.budget > $1.budget }
            .prefix(limit)
            .map { $0.advertiserId }
    }
    
    // MARK: - Payment Processing
    
    private func processPayment(amount: Double, description: String) async throws {
        // In production: Integrate with PaymentManager
        // Process payment via Apple Pay or stored payment method
        
        // Simulate payment processing
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Payment successful
        print("✅ Payment processed: $\(amount) for \(description)")
    }
    
    // MARK: - Analytics
    
    private func logAnalytics(event: String, campaignId: UUID, value: Double? = nil) {
        // In production: Send to analytics service
        print("📊 Analytics: \(event) for campaign \(campaignId)")
        if let value = value {
            print("   Value: $\(value)")
        }
    }
    
    // MARK: - Campaign Review (Admin)
    
    func approveCampaign(_ campaignId: UUID) {
        if let index = myCampaigns.firstIndex(where: { $0.id == campaignId }) {
            myCampaigns[index].status = .active
            activeCampaigns.append(myCampaigns[index])
        }
    }
    
    func rejectCampaign(_ campaignId: UUID, reason: String) {
        if let index = myCampaigns.firstIndex(where: { $0.id == campaignId }) {
            myCampaigns[index].status = .rejected
            // In production: Refund the advertiser
        }
    }
}

// MARK: - Errors

enum AdError: LocalizedError {
    case budgetTooLow(minimum: Double)
    case campaignNotFound
    case invalidTargeting
    case paymentFailed
    case campaignAlreadyActive
    
    var errorDescription: String? {
        switch self {
        case .budgetTooLow(let minimum):
            return "Budget too low. Minimum budget is $\(String(format: "%.2f", minimum))"
        case .campaignNotFound:
            return "Campaign not found"
        case .invalidTargeting:
            return "Invalid targeting parameters"
        case .paymentFailed:
            return "Payment processing failed"
        case .campaignAlreadyActive:
            return "You already have an active campaign of this type"
        }
    }
}

// MARK: - Revenue Extensions

extension AdvertisingManager {
    /// Calculate platform's ad revenue (we keep 100%)
    var platformAdRevenue: Double {
        return totalRevenue // We keep 100% of ad spend
    }
    
    /// Total platform revenue (contracts + ads)
    func totalPlatformRevenue(contractFees: Double) -> Double {
        return contractFees + platformAdRevenue
    }
    
    /// Ad revenue breakdown by type
    var revenueByType: [AdCampaignType: Double] {
        var breakdown: [AdCampaignType: Double] = [:]
        
        for campaign in myCampaigns {
            breakdown[campaign.campaignType, default: 0] += campaign.spent
        }
        
        return breakdown
    }
    
    /// Daily ad revenue
    func dailyRevenue(date: Date = Date()) -> Double {
        let calendar = Calendar.current
        return myCampaigns
            .filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
            .reduce(0) { $0 + $1.spent }
    }
}
