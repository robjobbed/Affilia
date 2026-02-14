//
//  VerificationRequest.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/4/26.
//

import Foundation

enum VerificationStatus: String, Codable {
    case pending = "PENDING"
    case approved = "APPROVED"
    case rejected = "REJECTED"
}

struct VerificationRequest: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var status: VerificationStatus
    var submittedDate: Date
    var reviewedDate: Date?
    var reviewedBy: String? // Admin username or ID
    var reviewNotes: String?
    
    // Verification criteria checklist
    var portfolioReviewed: Bool
    var githubReviewed: Bool
    var skillsVerified: Bool
    var professionalismScore: Int? // 1-5 rating
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        status: VerificationStatus = .pending,
        submittedDate: Date = Date(),
        reviewedDate: Date? = nil,
        reviewedBy: String? = nil,
        reviewNotes: String? = nil,
        portfolioReviewed: Bool = false,
        githubReviewed: Bool = false,
        skillsVerified: Bool = false,
        professionalismScore: Int? = nil
    ) {
        self.id = id
        self.userId = userId
        self.status = status
        self.submittedDate = submittedDate
        self.reviewedDate = reviewedDate
        self.reviewedBy = reviewedBy
        self.reviewNotes = reviewNotes
        self.portfolioReviewed = portfolioReviewed
        self.githubReviewed = githubReviewed
        self.skillsVerified = skillsVerified
        self.professionalismScore = professionalismScore
    }
}
