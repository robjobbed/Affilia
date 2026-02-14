//
//  Agent.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import Foundation

// MARK: - Agent Listing

/// Represents an AI agent/bot listed for hire on the platform
struct AgentListing: Identifiable, Codable {
    let id: UUID
    let ownerId: UUID // User who owns/created this agent
    var name: String
    var description: String
    var tagline: String // Short one-liner
    var capabilities: [AgentCapability]
    var category: AgentCategory
    var pricingModel: AgentPricingModel
    var technicalDetails: AgentTechnicalDetails
    var performanceMetrics: AgentPerformanceMetrics
    var status: AgentStatus
    var ownerInfo: AgentOwnerInfo
    var verificationStatus: AgentVerificationStatus
    var featuredUntil: Date?
    let createdAt: Date
    var updatedAt: Date
    var totalHires: Int
    var averageRating: Double
    var reviews: [AgentReview]
    
    // Computed properties
    var isAvailable: Bool {
        status == .available && verificationStatus == .verified
    }
    
    var monthlyRevenue: Double {
        // Calculate based on recent contracts (mock for now)
        return 0.0
    }
    
    init(
        id: UUID = UUID(),
        ownerId: UUID,
        name: String,
        description: String,
        tagline: String,
        capabilities: [AgentCapability],
        category: AgentCategory,
        pricingModel: AgentPricingModel,
        technicalDetails: AgentTechnicalDetails,
        performanceMetrics: AgentPerformanceMetrics = AgentPerformanceMetrics(),
        status: AgentStatus = .available,
        ownerInfo: AgentOwnerInfo,
        verificationStatus: AgentVerificationStatus = .pending,
        featuredUntil: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        totalHires: Int = 0,
        averageRating: Double = 0.0,
        reviews: [AgentReview] = []
    ) {
        self.id = id
        self.ownerId = ownerId
        self.name = name
        self.description = description
        self.tagline = tagline
        self.capabilities = capabilities
        self.category = category
        self.pricingModel = pricingModel
        self.technicalDetails = technicalDetails
        self.performanceMetrics = performanceMetrics
        self.status = status
        self.ownerInfo = ownerInfo
        self.verificationStatus = verificationStatus
        self.featuredUntil = featuredUntil
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.totalHires = totalHires
        self.averageRating = averageRating
        self.reviews = reviews
    }
}

// MARK: - Agent Enums

enum AgentCategory: String, CaseIterable, Codable {
    case coding = "Coding & Development"
    case design = "Design & Creative"
    case dataAnalysis = "Data Analysis"
    case contentCreation = "Content Creation"
    case automation = "Automation & Workflows"
    case testing = "Testing & QA"
    case devOps = "DevOps & Infrastructure"
    case research = "Research & Analysis"
    case customerSupport = "Customer Support"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .coding: return "chevron.left.forwardslash.chevron.right"
        case .design: return "paintbrush.fill"
        case .dataAnalysis: return "chart.bar.fill"
        case .contentCreation: return "doc.text.fill"
        case .automation: return "gearshape.2.fill"
        case .testing: return "checkmark.circle.fill"
        case .devOps: return "server.rack"
        case .research: return "magnifyingglass"
        case .customerSupport: return "person.2.fill"
        case .other: return "star.fill"
        }
    }
}

enum AgentStatus: String, Codable {
    case available = "Available"
    case busy = "Busy"
    case maintenance = "Under Maintenance"
    case retired = "Retired"
}

enum AgentVerificationStatus: String, Codable {
    case pending = "Pending Review"
    case verified = "Verified"
    case flagged = "Flagged"
    case rejected = "Rejected"
    
    var badge: String {
        switch self {
        case .verified: return "✓ Verified"
        case .pending: return "⏳ Pending"
        case .flagged: return "⚠️ Flagged"
        case .rejected: return "✗ Rejected"
        }
    }
}

// MARK: - Agent Capability

struct AgentCapability: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var examples: [String]
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        examples: [String] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.examples = examples
    }
}

// MARK: - Pricing Models

enum AgentPricingModel: Codable, Equatable {
    case perTask(Double) // Price per task executed
    case hourly(Double) // Hourly rate
    case monthly(Double) // Monthly subscription
    case custom(String) // Custom pricing with description
    
    var displayText: String {
        switch self {
        case .perTask(let price):
            return "$\(String(format: "%.2f", price)) per task"
        case .hourly(let rate):
            return "$\(String(format: "%.2f", rate))/hour"
        case .monthly(let price):
            return "$\(String(format: "%.2f", price))/month"
        case .custom(let description):
            return description
        }
    }
    
    var shortDisplay: String {
        switch self {
        case .perTask(let price):
            return "$\(String(format: "%.0f", price))/task"
        case .hourly(let rate):
            return "$\(String(format: "%.0f", rate))/hr"
        case .monthly(let price):
            return "$\(String(format: "%.0f", price))/mo"
        case .custom:
            return "Custom"
        }
    }
}

// MARK: - Technical Details

struct AgentTechnicalDetails: Codable {
    var framework: String // e.g., "OpenClaw", "LangChain", "Custom"
    var model: String? // e.g., "GPT-4", "Claude", "Local LLM"
    var hosting: AgentHosting
    var apiEndpoint: String?
    var repositoryURL: String? // GitHub/GitLab URL
    var documentation: String? // Link to docs
    var requiresAPIKey: Bool
    var environmentRequirements: [String]
    
    init(
        framework: String,
        model: String? = nil,
        hosting: AgentHosting,
        apiEndpoint: String? = nil,
        repositoryURL: String? = nil,
        documentation: String? = nil,
        requiresAPIKey: Bool = false,
        environmentRequirements: [String] = []
    ) {
        self.framework = framework
        self.model = model
        self.hosting = hosting
        self.apiEndpoint = apiEndpoint
        self.repositoryURL = repositoryURL
        self.documentation = documentation
        self.requiresAPIKey = requiresAPIKey
        self.environmentRequirements = environmentRequirements
    }
}

enum AgentHosting: String, Codable {
    case cloud = "Cloud-hosted (managed by owner)"
    case selfHosted = "Self-hosted (you provide infrastructure)"
    case hybrid = "Hybrid (flexible deployment)"
    
    var icon: String {
        switch self {
        case .cloud: return "cloud.fill"
        case .selfHosted: return "server.rack"
        case .hybrid: return "arrow.triangle.2.circlepath"
        }
    }
}

// MARK: - Performance Metrics

struct AgentPerformanceMetrics: Codable {
    var successRate: Double // 0.0 to 1.0
    var averageResponseTime: TimeInterval // in seconds
    var tasksCompleted: Int
    var uptime: Double // 0.0 to 1.0 (percentage)
    var lastActiveDate: Date?
    
    init(
        successRate: Double = 0.0,
        averageResponseTime: TimeInterval = 0.0,
        tasksCompleted: Int = 0,
        uptime: Double = 1.0,
        lastActiveDate: Date? = nil
    ) {
        self.successRate = min(max(successRate, 0.0), 1.0)
        self.averageResponseTime = averageResponseTime
        self.tasksCompleted = tasksCompleted
        self.uptime = min(max(uptime, 0.0), 1.0)
        self.lastActiveDate = lastActiveDate
    }
    
    var successRatePercentage: String {
        "\(Int(successRate * 100))%"
    }
    
    var uptimePercentage: String {
        "\(String(format: "%.1f", uptime * 100))%"
    }
    
    var responseTimeDisplay: String {
        if averageResponseTime < 1.0 {
            return "\(Int(averageResponseTime * 1000))ms"
        } else if averageResponseTime < 60 {
            return "\(String(format: "%.1f", averageResponseTime))s"
        } else {
            return "\(Int(averageResponseTime / 60))m"
        }
    }
}

// MARK: - Owner Info

struct AgentOwnerInfo: Codable {
    var xUsername: String
    var displayName: String
    var xProfileImageURL: String?
    var xVerified: Bool
    var totalAgentsListed: Int
    
    var handle: String {
        "@\(xUsername)"
    }
    
    init(
        xUsername: String,
        displayName: String,
        xProfileImageURL: String? = nil,
        xVerified: Bool = false,
        totalAgentsListed: Int = 1
    ) {
        self.xUsername = xUsername
        self.displayName = displayName
        self.xProfileImageURL = xProfileImageURL
        self.xVerified = xVerified
        self.totalAgentsListed = totalAgentsListed
    }
}

// MARK: - Agent Review

struct AgentReview: Identifiable, Codable {
    let id: UUID
    let agentId: UUID
    let reviewerId: UUID
    var reviewerName: String
    var reviewerHandle: String
    var rating: Int // 1-5
    var comment: String
    let createdAt: Date
    var contractId: UUID? // Optional link to contract
    
    init(
        id: UUID = UUID(),
        agentId: UUID,
        reviewerId: UUID,
        reviewerName: String,
        reviewerHandle: String,
        rating: Int,
        comment: String,
        createdAt: Date = Date(),
        contractId: UUID? = nil
    ) {
        self.id = id
        self.agentId = agentId
        self.reviewerId = reviewerId
        self.reviewerName = reviewerName
        self.reviewerHandle = reviewerHandle
        self.rating = min(max(rating, 1), 5)
        self.comment = comment
        self.createdAt = createdAt
        self.contractId = contractId
    }
}

// MARK: - Agent Contract

/// Extended contract for hiring agents
struct AgentContract: Identifiable, Codable {
    let id: UUID
    let hirerId: UUID
    let agentId: UUID
    let agentOwnerId: UUID
    var projectTitle: String
    var projectDescription: String
    var taskDescription: String
    var pricingModel: AgentPricingModel
    var estimatedDuration: TimeInterval?
    var totalAmount: Double
    let createdAt: Date
    var status: ContractStatus
    var startDate: Date?
    var completionDate: Date?
    var paymentId: String?
    
    /// Solomine's platform fee (5%)
    var platformFee: Double {
        totalAmount * 0.05
    }
    
    /// Amount agent owner receives
    var ownerAmount: Double {
        totalAmount - platformFee
    }
    
    init(
        id: UUID = UUID(),
        hirerId: UUID,
        agentId: UUID,
        agentOwnerId: UUID,
        projectTitle: String,
        projectDescription: String,
        taskDescription: String,
        pricingModel: AgentPricingModel,
        estimatedDuration: TimeInterval? = nil,
        totalAmount: Double,
        createdAt: Date = Date(),
        status: ContractStatus = .draft,
        startDate: Date? = nil,
        completionDate: Date? = nil,
        paymentId: String? = nil
    ) {
        self.id = id
        self.hirerId = hirerId
        self.agentId = agentId
        self.agentOwnerId = agentOwnerId
        self.projectTitle = projectTitle
        self.projectDescription = projectDescription
        self.taskDescription = taskDescription
        self.pricingModel = pricingModel
        self.estimatedDuration = estimatedDuration
        self.totalAmount = totalAmount
        self.createdAt = createdAt
        self.status = status
        self.startDate = startDate
        self.completionDate = completionDate
        self.paymentId = paymentId
    }
}

// MARK: - Sample Data

extension AgentListing {
    static let sample = AgentListing(
        ownerId: UUID(),
        name: "CodeClaw Pro",
        description: """
        Advanced coding agent built on OpenClaw. Specializes in Swift, Python, and JavaScript. 
        Can write tests, fix bugs, refactor code, and build features from specifications.
        
        • Trained on millions of lines of production code
        • Integrates with GitHub for PR reviews
        • Supports iOS, web, and backend development
        • Includes automated testing and deployment
        """,
        tagline: "Your AI coding partner that never sleeps",
        capabilities: [
            AgentCapability(
                name: "Code Generation",
                description: "Write production-ready code in Swift, Python, JS, and more",
                examples: ["SwiftUI views", "REST APIs", "Database migrations"]
            ),
            AgentCapability(
                name: "Bug Fixing",
                description: "Analyze and fix bugs with explanations",
                examples: ["Memory leaks", "Logic errors", "Performance issues"]
            ),
            AgentCapability(
                name: "Code Review",
                description: "Review PRs and suggest improvements",
                examples: ["Style feedback", "Security checks", "Performance tips"]
            )
        ],
        category: .coding,
        pricingModel: .perTask(25.00),
        technicalDetails: AgentTechnicalDetails(
            framework: "OpenClaw",
            model: "GPT-4 + Custom Fine-tuning",
            hosting: .cloud,
            repositoryURL: "https://github.com/example/codeclaw-pro",
            documentation: "https://docs.example.com/codeclaw",
            requiresAPIKey: false,
            environmentRequirements: ["macOS 13+", "Xcode 15+"]
        ),
        performanceMetrics: AgentPerformanceMetrics(
            successRate: 0.94,
            averageResponseTime: 45.0,
            tasksCompleted: 1847,
            uptime: 0.995,
            lastActiveDate: Date()
        ),
        ownerInfo: AgentOwnerInfo(
            xUsername: "robcodes",
            displayName: "Rob Behbahani",
            xVerified: true,
            totalAgentsListed: 3
        ),
        verificationStatus: .verified,
        totalHires: 234,
        averageRating: 4.8,
        reviews: [
            AgentReview(
                agentId: UUID(),
                reviewerId: UUID(),
                reviewerName: "Sarah Chen",
                reviewerHandle: "@sarahbuilds",
                rating: 5,
                comment: "CodeClaw Pro saved me 20 hours of work. The code quality is excellent!"
            )
        ]
    )
    
    static let samples: [AgentListing] = [
        sample,
        AgentListing(
            ownerId: UUID(),
            name: "DesignBot Studio",
            description: "AI agent for generating UI/UX designs and assets",
            tagline: "Beautiful designs, zero manual work",
            capabilities: [],
            category: .design,
            pricingModel: .hourly(50.00),
            technicalDetails: AgentTechnicalDetails(framework: "Custom", hosting: .cloud),
            ownerInfo: AgentOwnerInfo(xUsername: "designpro", displayName: "Design Pro"),
            verificationStatus: .verified,
            totalHires: 89,
            averageRating: 4.6
        ),
        AgentListing(
            ownerId: UUID(),
            name: "DataCruncher AI",
            description: "Analyze datasets and generate insights automatically",
            tagline: "Turn data into decisions instantly",
            capabilities: [],
            category: .dataAnalysis,
            pricingModel: .monthly(199.00),
            technicalDetails: AgentTechnicalDetails(framework: "LangChain", hosting: .hybrid),
            ownerInfo: AgentOwnerInfo(xUsername: "datawhiz", displayName: "Data Whiz"),
            verificationStatus: .verified,
            totalHires: 156,
            averageRating: 4.9
        )
    ]
}
