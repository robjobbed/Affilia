//
//  AgentMarketplaceIntegration.swift
//  Affilia
//
//  Integration guide for adding Agent Marketplace to your app
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI
internal import Combine

// MARK: - Integration Examples

/*
 
 ## Adding Agent Marketplace to Your Navigation
 
 ### Option 1: Add as a Tab (Recommended)
 
 If you have a TabView in your main interface, add the Agent Marketplace as a new tab:
 
 ```swift
 TabView {
     // Existing tabs...
     
     ExploreView()
         .tabItem {
             Label("Explore", systemImage: "magnifyingglass")
         }
     
     // NEW: Agent Marketplace Tab
     AgentMarketplaceView()
         .tabItem {
             Label("Agents", systemImage: "sparkles")
         }
     
     GigsView()
         .tabItem {
             Label("Gigs", systemImage: "briefcase")
         }
     
     // ... other tabs
 }
 ```
 
 ### Option 2: Add to Explore View
 
 Add a section in your ExploreView to feature AI agents:
 
 ```swift
 struct ExploreView: View {
     var body: some View {
         ScrollView {
             VStack(spacing: Theme.Spacing.lg) {
                 // Existing content...
                 
                 // NEW: Agents Section
                 VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                     HStack {
                         Text("🤖 AI Agents")
                             .font(Theme.Typography.h3)
                         
                         Spacer()
                         
                         NavigationLink("See All") {
                             AgentMarketplaceView()
                         }
                     }
                     
                     Text("Hire autonomous bots to work for you")
                         .font(Theme.Typography.small)
                         .foregroundColor(Theme.Colors.textSecondary)
                     
                     // Featured agents carousel
                     ScrollView(.horizontal, showsIndicators: false) {
                         HStack(spacing: Theme.Spacing.md) {
                             ForEach(AgentListing.samples.prefix(3)) { agent in
                                 NavigationLink {
                                     AgentDetailView(agent: agent)
                                 } label: {
                                     AgentCard(agent: agent) { }
                                         .frame(width: 160)
                                 }
                             }
                         }
                     }
                 }
                 .padding(Theme.Spacing.md)
             }
         }
     }
 }
 ```
 
 ### Option 3: Add to User Profile (Builder Dashboard)
 
 If you're a builder, add "My Agents" section to your profile:
 
 ```swift
 struct FreelancerDashboardView: View {
     @StateObject private var agentManager = AgentManager.shared
     
     var body: some View {
         VStack {
             // Existing dashboard content...
             
             // NEW: My Agents Section
             VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                 HStack {
                     Text("My Agents")
                         .font(Theme.Typography.h3)
                     
                     Spacer()
                     
                     Button {
                         showingCreateAgent = true
                     } label: {
                         Label("Add Agent", systemImage: "plus.circle.fill")
                             .font(Theme.Typography.small)
                             .foregroundColor(Theme.Colors.accent)
                     }
                 }
                 
                 if agentManager.myAgents.isEmpty {
                     AgentEmptyStateView(
                         icon: "sparkles",
                         title: "No agents yet",
                         subtitle: "List your AI agents and earn passive income"
                     )
                 } else {
                     ForEach(agentManager.myAgents) { agent in
                         MyAgentCard(agent: agent)
                     }
                 }
             }
             .padding(Theme.Spacing.md)
         }
         .sheet(isPresented: $showingCreateAgent) {
             CreateAgentListingView()
         }
     }
 }
 ```
 
 ## Managing User's Agents
 
 Create an AgentManager to handle user's listed agents:
 
 */

// MARK: - Agent Manager

@MainActor
class AgentManager: ObservableObject {
    static let shared = AgentManager()
    
    @Published var myAgents: [AgentListing] = []
    @Published var agentContracts: [AgentContract] = []
    
    private init() {
        loadMyAgents()
    }
    
    func loadMyAgents() {
        // In production: Fetch from API
        // For now, return empty or sample data
        myAgents = []
    }
    
    func createAgent(_ agent: AgentListing) {
        // Submit to backend for review
        myAgents.append(agent)
    }
    
    func updateAgent(_ agent: AgentListing) {
        if let index = myAgents.firstIndex(where: { $0.id == agent.id }) {
            myAgents[index] = agent
        }
    }
    
    func deleteAgent(_ agentId: UUID) {
        myAgents.removeAll { $0.id == agentId }
    }
    
    func loadAgentContracts() {
        // Fetch contracts where your agents were hired
        agentContracts = []
    }
    
    func totalAgentRevenue() -> Double {
        // Calculate total earnings from agents
        return agentContracts
            .filter { $0.status == .completed }
            .reduce(0) { $0 + $1.ownerAmount }
    }
}

// MARK: - My Agent Card

struct MyAgentCard: View {
    let agent: AgentListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Text(agent.name)
                    .font(Theme.Typography.body.weight(.bold))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                AgentStatusBadge(status: agent.status)
            }
            
            Text(agent.tagline)
                .font(Theme.Typography.small)
                .foregroundColor(Theme.Colors.textSecondary)
                .lineLimit(2)
            
            Divider().background(Theme.Colors.border)
            
            HStack(spacing: Theme.Spacing.lg) {
                AgentMetricView(
                    label: "Hires",
                    value: "\(agent.totalHires)",
                    icon: "person.2.fill",
                    color: .green
                )
                
                AgentMetricView(
                    label: "Rating",
                    value: String(format: "%.1f", agent.averageRating),
                    icon: "star.fill",
                    color: .yellow
                )
                
                AgentMetricView(
                    label: "Revenue",
                    value: "$\(Int(agent.monthlyRevenue))",
                    icon: "dollarsign.circle.fill",
                    color: .blue
                )
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

// MARK: - Agent Status Badge

struct AgentStatusBadge: View {
    let status: AgentStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(Theme.Typography.tiny)
            .fontWeight(.medium)
            .foregroundColor(textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(6)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .available:
            return .green.opacity(0.15)
        case .busy:
            return .orange.opacity(0.15)
        case .maintenance:
            return .yellow.opacity(0.15)
        case .retired:
            return .gray.opacity(0.15)
        }
    }
    
    private var textColor: Color {
        switch status {
        case .available:
            return .green
        case .busy:
            return .orange
        case .maintenance:
            return .yellow
        case .retired:
            return .gray
        }
    }
}

struct AgentMetricView: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundColor(color)
                Text(label)
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Text(value)
                .font(Theme.Typography.small.weight(.bold))
                .foregroundColor(Theme.Colors.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Agent Empty State

struct AgentEmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(Theme.Colors.textSecondary.opacity(0.3))
            
            Text(title)
                .font(Theme.Typography.body.weight(.bold))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text(subtitle)
                .font(Theme.Typography.small)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity)
    }
}

/*
 
 ## Backend API Endpoints Needed
 
 ### Agent CRUD
 
 ```
 GET    /api/agents              - List all agents (with filters)
 GET    /api/agents/:id          - Get agent details
 POST   /api/agents              - Create new agent (requires auth)
 PUT    /api/agents/:id          - Update agent (owner only)
 DELETE /api/agents/:id          - Delete agent (owner only)
 
 GET    /api/agents/my           - Get user's agents
 GET    /api/agents/featured     - Get featured agents
 ```
 
 ### Agent Hiring
 
 ```
 POST   /api/agents/:id/hire     - Hire an agent
 GET    /api/agents/:id/contracts - Get contracts for agent
 POST   /api/agents/:id/review   - Submit review for agent
 ```
 
 ### Performance Metrics
 
 ```
 GET    /api/agents/:id/metrics  - Get performance metrics
 POST   /api/agents/:id/metrics  - Update metrics (system only)
 ```
 
 ## Payment Integration
 
 Extend your existing PaymentManager:
 
 */

extension PaymentManager {
    /// Process payment for hiring an agent
    func processAgentHire(contract: AgentContract) async throws -> PaymentRecord {
        // 1. Validate contract
        guard contract.totalAmount > 0 else {
            throw PaymentError.invalidAmount
        }
        
        // 2. Create payment request
        let totalCost = contract.totalAmount + contract.platformFee
        
        // 3. Process with Apple Pay
        let payment = try await processApplePayPayment(
            amount: totalCost,
            description: "Agent: \(contract.projectTitle)"
        )
        
        // 4. Update contract status
        var updatedContract = contract
        updatedContract.status = .active
        updatedContract.startDate = Date()
        updatedContract.paymentId = payment.transactionId
        
        // 5. Notify agent owner
        notifyAgentOwner(contract: updatedContract)
        
        // 6. Trigger agent to start work
        startAgentWork(contract: updatedContract)
        
        return payment
    }
    
    private func notifyAgentOwner(contract: AgentContract) {
        // Send notification to agent owner
    }
    
    private func startAgentWork(contract: AgentContract) {
        // Trigger agent API/webhook to start work
    }
}

/*
 
 ## Database Schema
 
 ### agents table
 
 ```sql
 CREATE TABLE agents (
     id UUID PRIMARY KEY,
     owner_id UUID REFERENCES users(id),
     name VARCHAR(255) NOT NULL,
     tagline VARCHAR(255),
     description TEXT,
     category VARCHAR(100),
     pricing_model JSONB,
     technical_details JSONB,
     status VARCHAR(50),
     verification_status VARCHAR(50),
     featured_until TIMESTAMP,
     created_at TIMESTAMP DEFAULT NOW(),
     updated_at TIMESTAMP DEFAULT NOW()
 );
 ```
 
 ### agent_capabilities table
 
 ```sql
 CREATE TABLE agent_capabilities (
     id UUID PRIMARY KEY,
     agent_id UUID REFERENCES agents(id),
     name VARCHAR(255),
     description TEXT,
     examples JSONB,
     created_at TIMESTAMP DEFAULT NOW()
 );
 ```
 
 ### agent_contracts table
 
 ```sql
 CREATE TABLE agent_contracts (
     id UUID PRIMARY KEY,
     hirer_id UUID REFERENCES users(id),
     agent_id UUID REFERENCES agents(id),
     agent_owner_id UUID REFERENCES users(id),
     project_title VARCHAR(255),
     project_description TEXT,
     task_description TEXT,
     pricing_model JSONB,
     total_amount DECIMAL(10, 2),
     status VARCHAR(50),
     start_date TIMESTAMP,
     completion_date TIMESTAMP,
     payment_id VARCHAR(255),
     created_at TIMESTAMP DEFAULT NOW()
 );
 ```
 
 ### agent_reviews table
 
 ```sql
 CREATE TABLE agent_reviews (
     id UUID PRIMARY KEY,
     agent_id UUID REFERENCES agents(id),
     reviewer_id UUID REFERENCES users(id),
     rating INTEGER CHECK (rating >= 1 AND rating <= 5),
     comment TEXT,
     contract_id UUID REFERENCES agent_contracts(id),
     created_at TIMESTAMP DEFAULT NOW()
 );
 ```
 
 ### agent_metrics table
 
 ```sql
 CREATE TABLE agent_metrics (
     id UUID PRIMARY KEY,
     agent_id UUID REFERENCES agents(id),
     success_rate DECIMAL(5, 4),
     average_response_time INTEGER, -- in milliseconds
     tasks_completed INTEGER,
     uptime DECIMAL(5, 4),
     last_active_date TIMESTAMP,
     updated_at TIMESTAMP DEFAULT NOW()
 );
 ```
 
 ## Next Steps
 
 1. ✅ Models created (ModelsAgent.swift)
 2. ✅ Views created (ViewsAgentMarketplaceView.swift, etc.)
 3. 🔲 Add navigation integration to your app
 4. 🔲 Implement backend API endpoints
 5. 🔲 Set up database tables
 6. 🔲 Connect payment processing
 7. 🔲 Test agent listing flow
 8. 🔲 Test agent hiring flow
 9. 🔲 Implement agent verification system
 10. 🔲 Add performance tracking
 
 */
