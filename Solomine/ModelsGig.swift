//
//  Gig.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import Foundation

enum GigCategory: String, CaseIterable, Codable {
    case content = "CONTENT"
    case influencers = "INFLUENCERS"
    case paidSocial = "PAID SOCIAL"
    case email = "EMAIL"
    case seo = "SEO"
    case coupon = "COUPON"
    case communities = "COMMUNITIES"
    case other = "OTHER"
}

struct Gig: Identifiable, Codable, Hashable {
    let id: UUID
    var freelancerId: UUID
    var title: String
    var description: String
    var deliverables: [String]
    var turnaroundDays: Int
    var price: Double
    var categories: [GigCategory]
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        freelancerId: UUID,
        title: String,
        description: String,
        deliverables: [String],
        turnaroundDays: Int,
        price: Double,
        categories: [GigCategory],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.freelancerId = freelancerId
        self.title = title
        self.description = description
        self.deliverables = deliverables
        self.turnaroundDays = turnaroundDays
        self.price = price
        self.categories = categories
        self.createdAt = createdAt
    }
}
