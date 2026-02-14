//
//  Payment.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import Foundation

// MARK: - Payment Models

/// Represents a contract between hirer and freelancer
struct Contract: Identifiable, Codable {
    let id: UUID
    let hirerId: UUID
    let freelancerId: UUID
    let projectTitle: String
    let projectDescription: String
    let totalAmount: Double
    let paymentStructure: PaymentStructure
    let milestones: [Milestone]
    let createdAt: Date
    var status: ContractStatus
    var signedByHirer: Bool
    var signedByFreelancer: Bool
    var signedAt: Date?
    
    /// Solomine's 5% platform fee
    var platformFee: Double {
        totalAmount * 0.05
    }
    
    /// Amount freelancer receives (95% of total)
    var freelancerAmount: Double {
        totalAmount - platformFee
    }
    
    /// Total amount hirer pays (includes platform fee)
    var hirerTotalCost: Double {
        // If paying upfront or in milestones, hirer pays contract value only
        // If paying at end, hirer pays contract value + platform fee
        switch paymentStructure {
        case .upfront, .milestones:
            return totalAmount
        case .afterCompletion:
            return totalAmount + platformFee
        }
    }
    
    init(
        id: UUID = UUID(),
        hirerId: UUID,
        freelancerId: UUID,
        projectTitle: String,
        projectDescription: String,
        totalAmount: Double,
        paymentStructure: PaymentStructure,
        milestones: [Milestone] = [],
        createdAt: Date = Date(),
        status: ContractStatus = .draft,
        signedByHirer: Bool = false,
        signedByFreelancer: Bool = false,
        signedAt: Date? = nil
    ) {
        self.id = id
        self.hirerId = hirerId
        self.freelancerId = freelancerId
        self.projectTitle = projectTitle
        self.projectDescription = projectDescription
        self.totalAmount = totalAmount
        self.paymentStructure = paymentStructure
        self.milestones = milestones
        self.createdAt = createdAt
        self.status = status
        self.signedByHirer = signedByHirer
        self.signedByFreelancer = signedByFreelancer
        self.signedAt = signedAt
    }
}

enum ContractStatus: String, Codable {
    case draft
    case pendingSignature
    case active
    case completed
    case disputed
    case cancelled
}

/// Payment structure options
enum PaymentStructure: Codable, Equatable {
    case upfront // Pay 100% upfront
    case afterCompletion // Pay 100% after project completion (hirer pays platform fee)
    case milestones([MilestonePercentage]) // Pay in milestones
    
    var displayName: String {
        switch self {
        case .upfront:
            return "Pay Upfront (100%)"
        case .afterCompletion:
            return "Pay After Completion (+5% fee)"
        case .milestones:
            return "Pay in Milestones"
        }
    }
    
    var description: String {
        switch self {
        case .upfront:
            return "Pay the full amount before work begins. Freelancer gets paid immediately."
        case .afterCompletion:
            return "Pay after project is completed. You'll pay an additional 5% platform fee to cover the freelancer's cost."
        case .milestones(let percentages):
            return "Pay in \(percentages.count) milestone(s) as work progresses."
        }
    }
}

struct MilestonePercentage: Codable, Equatable {
    let percentage: Double // 0.0 to 1.0
    let description: String
    
    init(percentage: Double, description: String) {
        self.percentage = min(max(percentage, 0.0), 1.0)
        self.description = description
    }
}

/// Individual milestone in a contract
struct Milestone: Identifiable, Codable {
    let id: UUID
    let contractId: UUID
    let title: String
    let description: String
    let amount: Double // Includes platform fee already calculated
    let percentage: Double // What % of total contract this represents
    let order: Int
    var status: MilestoneStatus
    var completedAt: Date?
    var paidAt: Date?
    var paymentId: String?
    
    /// Platform fee for this milestone (5%)
    var platformFee: Double {
        amount * 0.05 / 1.05 // Back-calculate since amount includes fee
    }
    
    /// Amount freelancer receives
    var freelancerAmount: Double {
        amount - platformFee
    }
    
    init(
        id: UUID = UUID(),
        contractId: UUID,
        title: String,
        description: String,
        amount: Double,
        percentage: Double,
        order: Int,
        status: MilestoneStatus = .pending,
        completedAt: Date? = nil,
        paidAt: Date? = nil,
        paymentId: String? = nil
    ) {
        self.id = id
        self.contractId = contractId
        self.title = title
        self.description = description
        self.amount = amount
        self.percentage = percentage
        self.order = order
        self.status = status
        self.completedAt = completedAt
        self.paidAt = paidAt
        self.paymentId = paymentId
    }
}

enum MilestoneStatus: String, Codable {
    case pending
    case inProgress
    case completed
    case paid
    case disputed
}

/// Payment transaction record
struct Payment: Identifiable, Codable {
    let id: UUID
    let contractId: UUID
    let milestoneId: UUID?
    let payerId: UUID
    let recipientId: UUID
    let amount: Double
    let platformFee: Double
    let freelancerAmount: Double
    let paymentMethod: PaymentMethod
    let transactionId: String
    let status: PaymentStatus
    let createdAt: Date
    var processedAt: Date?
    var failureReason: String?
    
    init(
        id: UUID = UUID(),
        contractId: UUID,
        milestoneId: UUID? = nil,
        payerId: UUID,
        recipientId: UUID,
        amount: Double,
        platformFee: Double,
        freelancerAmount: Double,
        paymentMethod: PaymentMethod,
        transactionId: String,
        status: PaymentStatus,
        createdAt: Date = Date(),
        processedAt: Date? = nil,
        failureReason: String? = nil
    ) {
        self.id = id
        self.contractId = contractId
        self.milestoneId = milestoneId
        self.payerId = payerId
        self.recipientId = recipientId
        self.amount = amount
        self.platformFee = platformFee
        self.freelancerAmount = freelancerAmount
        self.paymentMethod = paymentMethod
        self.transactionId = transactionId
        self.status = status
        self.createdAt = createdAt
        self.processedAt = processedAt
        self.failureReason = failureReason
    }
}

enum PaymentMethod: String, Codable {
    case applePay
    case card
    case bankTransfer
    case escrow
}

enum PaymentStatus: String, Codable {
    case pending
    case processing
    case completed
    case failed
    case refunded
}

// MARK: - Helper Extensions

extension Contract {
    /// Calculate milestone amounts based on percentages
    static func createMilestones(
        contractId: UUID,
        totalAmount: Double,
        percentages: [MilestonePercentage]
    ) -> [Milestone] {
        return percentages.enumerated().map { index, milestone in
            let amount = totalAmount * milestone.percentage
            return Milestone(
                contractId: contractId,
                title: "Milestone \(index + 1)",
                description: milestone.description,
                amount: amount,
                percentage: milestone.percentage,
                order: index + 1
            )
        }
    }
    
    /// Get payment breakdown for display
    func paymentBreakdown() -> PaymentBreakdown {
        PaymentBreakdown(
            contractValue: totalAmount,
            platformFee: platformFee,
            freelancerReceives: freelancerAmount,
            hirerPays: hirerTotalCost,
            hirerPaysAdditionalFee: paymentStructure == .afterCompletion
        )
    }
}

struct PaymentBreakdown {
    let contractValue: Double
    let platformFee: Double
    let freelancerReceives: Double
    let hirerPays: Double
    let hirerPaysAdditionalFee: Bool
    
    var breakdownText: String {
        var text = """
        Contract Value: $\(String(format: "%.2f", contractValue))
        Platform Fee (5%): $\(String(format: "%.2f", platformFee))
        Freelancer Receives: $\(String(format: "%.2f", freelancerReceives))
        """
        
        if hirerPaysAdditionalFee {
            text += "\n\nYou Pay: $\(String(format: "%.2f", hirerPays))"
            text += "\n(Includes $\(String(format: "%.2f", platformFee)) platform fee)"
        } else {
            text += "\n\nYou Pay: $\(String(format: "%.2f", hirerPays))"
            text += "\n(Platform fee deducted from contract value)"
        }
        
        return text
    }
}

// MARK: - Common Payment Structures

extension PaymentStructure {
    /// Standard milestone templates
    static let twoMilestones = PaymentStructure.milestones([
        MilestonePercentage(percentage: 0.5, description: "50% upfront"),
        MilestonePercentage(percentage: 0.5, description: "50% on completion")
    ])
    
    static let threeMilestones = PaymentStructure.milestones([
        MilestonePercentage(percentage: 0.33, description: "33% upfront"),
        MilestonePercentage(percentage: 0.34, description: "34% at midpoint"),
        MilestonePercentage(percentage: 0.33, description: "33% on completion")
    ])
    
    static let fourMilestones = PaymentStructure.milestones([
        MilestonePercentage(percentage: 0.25, description: "25% upfront"),
        MilestonePercentage(percentage: 0.25, description: "25% at 25% progress"),
        MilestonePercentage(percentage: 0.25, description: "25% at 75% progress"),
        MilestonePercentage(percentage: 0.25, description: "25% on completion")
    ])
}
