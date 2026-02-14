//
//  FreelancerProfile.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import Foundation

enum AvailabilityStatus: String, CaseIterable, Codable {
    case openToWork = "OPEN TO WORK"
    case booked = "BOOKED"
    case selective = "SELECTIVE"
}

struct FreelancerProfile: Identifiable, Codable {
    let id: UUID
    var xUsername: String // X handle WITHOUT @ (e.g., "robcodes")
    var displayName: String
    var bio: String
    var skills: [String]
    var portfolioProjects: [PortfolioProject]
    var hourlyRate: Double?
    var projectBasedPricing: Double?
    var availability: AvailabilityStatus
    var projectsCompleted: Int
    var averageRating: Double
    var memberSince: Date
    
    // X-specific data for credibility
    var xFollowers: Int
    var xFollowing: Int
    var xVerified: Bool
    var xProfileImageURL: String?
    
    // Affilia verification status
    var isVerifiedCoder: Bool
    var verificationDate: Date?
    var verificationNotes: String?
    
    // Computed property for handle with @
    var handle: String {
        "@\(xUsername)"
    }
    
    init(
        id: UUID = UUID(),
        xUsername: String,
        displayName: String,
        bio: String,
        skills: [String],
        portfolioProjects: [PortfolioProject] = [],
        hourlyRate: Double? = nil,
        projectBasedPricing: Double? = nil,
        availability: AvailabilityStatus = .openToWork,
        projectsCompleted: Int = 0,
        averageRating: Double = 5.0,
        memberSince: Date = Date(),
        xFollowers: Int = 0,
        xFollowing: Int = 0,
        xVerified: Bool = false,
        xProfileImageURL: String? = nil,
        isVerifiedCoder: Bool = false,
        verificationDate: Date? = nil,
        verificationNotes: String? = nil
    ) {
        self.id = id
        self.xUsername = xUsername
        self.displayName = displayName
        self.bio = bio
        self.skills = skills
        self.portfolioProjects = portfolioProjects
        self.hourlyRate = hourlyRate
        self.projectBasedPricing = projectBasedPricing
        self.availability = availability
        self.projectsCompleted = projectsCompleted
        self.averageRating = averageRating
        self.memberSince = memberSince
        self.xFollowers = xFollowers
        self.xFollowing = xFollowing
        self.xVerified = xVerified
        self.xProfileImageURL = xProfileImageURL
        self.isVerifiedCoder = isVerifiedCoder
        self.verificationDate = verificationDate
        self.verificationNotes = verificationNotes
    }
}

struct PortfolioProject: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var imageURL: String? // Placeholder for now
    var projectURL: String?
    var githubURL: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        imageURL: String? = nil,
        projectURL: String? = nil,
        githubURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.projectURL = projectURL
        self.githubURL = githubURL
    }
}
