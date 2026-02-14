//
//  UserRole.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import Foundation

enum UserRole: String, Codable {
    case builder = "AFFILIATE"
    case hirer = "COMPANY"
    
    var displayTitle: String {
        switch self {
        case .builder:
            return "AFFILIATE"
        case .hirer:
            return "COMPANY"
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self).uppercased()
        
        switch rawValue {
        case "AFFILIATE", "I BUILD":
            self = .builder
        case "COMPANY", "I HIRE":
            self = .hirer
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid role value: \(rawValue)"
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

struct User: Identifiable, Codable {
    let id: UUID
    var email: String
    var role: UserRole?  // Optional - set after authentication in RoleSelectionView
    var freelancerProfile: FreelancerProfile?
    var shortlistedFreelancers: [UUID]
    
    init(
        id: UUID = UUID(),
        email: String,
        role: UserRole? = nil,  // Default to nil - user selects role after auth
        freelancerProfile: FreelancerProfile? = nil,
        shortlistedFreelancers: [UUID] = []
    ) {
        self.id = id
        self.email = email
        self.role = role
        self.freelancerProfile = freelancerProfile
        self.shortlistedFreelancers = shortlistedFreelancers
    }
}
