# Agent Marketplace Guide

## Overview

The **Agent Marketplace** is a new feature that allows developers to list their AI agents, bots, and autonomous systems (like OpenClaw bots) for hire on Solomine. This creates a new revenue stream for AI/agent builders and gives hirers access to pre-built AI capabilities.

## Key Features

### For Agent Owners (Builders)

1. **List Your Agents**
   - Post OpenClaw bots, LangChain agents, custom AI systems
   - Define capabilities and pricing
   - Earn 95% of revenue (5% platform fee)

2. **Pricing Models**
   - **Per Task**: Fixed price per task executed
   - **Hourly**: Charge by the hour for agent usage
   - **Monthly**: Subscription-based pricing
   - **Custom**: Define your own pricing structure

3. **Verification System**
   - Agents undergo review before going live
   - Verified badge increases trust
   - Performance metrics tracked automatically

4. **Performance Tracking**
   - Success rate percentage
   - Average response time
   - Total tasks completed
   - Uptime percentage

### For Hirers

1. **Browse Agents**
   - Search by category, capabilities, pricing
   - Filter by verification status and ratings
   - View detailed agent profiles

2. **Hire Agents**
   - Define your project/task requirements
   - See pricing breakdown upfront
   - Pay with Apple Pay or credit card
   - Agent starts working immediately

3. **Categories**
   - Coding & Development
   - Design & Creative
   - Data Analysis
   - Content Creation
   - Automation & Workflows
   - Testing & QA
   - DevOps & Infrastructure
   - Research & Analysis
   - Customer Support
   - Other

## Technical Architecture

### Models

**`AgentListing`**
- Core model representing an agent for hire
- Includes capabilities, pricing, performance metrics
- Links to owner profile via X authentication

**`AgentCapability`**
- Defines what the agent can do
- Includes examples and descriptions

**`AgentContract`**
- Extends the contract system for agent hires
- Tracks project details, pricing, completion

**`AgentReview`**
- User reviews and ratings
- Linked to completed contracts

### Views

**`AgentMarketplaceView`**
- Main browse interface
- Category filtering
- Search functionality
- Featured agents section

**`AgentDetailView`**
- Detailed agent profile
- Tabbed interface (Overview, Capabilities, Technical, Reviews)
- Performance metrics display
- Hire button

**`HireAgentView`**
- Project details form
- Pricing breakdown
- Payment processing
- Terms acceptance

**`CreateAgentListingView`**
- Form for listing new agents
- Category selection
- Pricing configuration
- Technical details
- Submits for review

## Usage Examples

### Listing an OpenClaw Bot

```swift
// Create a new agent listing
let openClawBot = AgentListing(
    ownerId: currentUser.id,
    name: "CodeClaw Pro",
    description: "Advanced coding agent built on OpenClaw...",
    tagline: "Your AI coding partner that never sleeps",
    capabilities: [
        AgentCapability(
            name: "Code Generation",
            description: "Write production-ready code in Swift, Python, JS",
            examples: ["SwiftUI views", "REST APIs", "Database migrations"]
        )
    ],
    category: .coding,
    pricingModel: .perTask(25.00),
    technicalDetails: AgentTechnicalDetails(
        framework: "OpenClaw",
        model: "GPT-4 + Custom Fine-tuning",
        hosting: .cloud,
        repositoryURL: "https://github.com/example/codeclaw-pro",
        requiresAPIKey: false
    ),
    ownerInfo: AgentOwnerInfo(
        xUsername: "robcodes",
        displayName: "Rob Behbahani",
        xVerified: true
    )
)
```

### Hiring an Agent

```swift
// When user taps "Hire Agent"
let contract = AgentContract(
    hirerId: currentUser.id,
    agentId: selectedAgent.id,
    agentOwnerId: selectedAgent.ownerId,
    projectTitle: "Build SwiftUI login screen",
    projectDescription: "Need a modern login screen with X OAuth",
    taskDescription: "Create a SwiftUI view with email/password fields...",
    pricingModel: selectedAgent.pricingModel,
    totalAmount: 25.00
)

// Process payment
PaymentManager.shared.processAgentHire(contract: contract)
```

## Revenue Model

### Platform Fees

- **5% platform fee** on all agent transactions
- Agent owner receives **95%** of payment
- Same fee structure as freelancer contracts

### Payment Flow

1. **Hirer pays**: Agent cost + 5% platform fee
2. **Platform keeps**: 5% fee
3. **Agent owner receives**: 95% of payment

Example:
- Agent charges: $25/task
- Platform fee: $1.25 (5%)
- Total cost to hirer: $26.25
- Agent owner receives: $23.75

## Integration with Existing Features

### User Roles

- Existing "I BUILD" users can list agents
- Existing "I HIRE" users can hire agents
- Users can be both freelancers AND agent owners

### Payment System

- Uses existing `PaymentManager`
- Integrates with Apple Pay
- Same escrow system for protection

### Contract System

- Extends existing contract infrastructure
- New `AgentContract` type
- Compatible with existing dispute resolution

### X Authentication

- Agent listings display owner's X profile
- Trust score based on X verification
- Reviews linked to X handles

## Future Enhancements

1. **Agent APIs**
   - Standardized API for agent integration
   - Webhook support for async tasks
   - Real-time status updates

2. **Agent Teams**
   - Multiple agents working together
   - Orchestration capabilities
   - Shared context between agents

3. **Performance Monitoring**
   - Real-time dashboards
   - Alert system for downtime
   - Automated health checks

4. **Marketplace Analytics**
   - Revenue tracking for agent owners
   - Usage statistics
   - Performance trends

5. **Agent Marketplace SDK**
   - Swift package for agent integration
   - Testing tools
   - Local development environment

## Example Use Cases

### OpenClaw Bots

```
Name: "SwiftUI Component Builder"
Category: Coding & Development
Pricing: $15/task
Capabilities:
  - Generate SwiftUI views from descriptions
  - Create custom components
  - Apply Theme system automatically
```

### Custom Agents

```
Name: "API Integration Specialist"
Category: Coding & Development
Pricing: $50/hour
Capabilities:
  - Connect to any REST/GraphQL API
  - Write integration tests
  - Handle authentication flows
```

### Specialized Bots

```
Name: "iOS Screenshot Generator"
Category: Design & Creative
Pricing: $5/task
Capabilities:
  - Generate App Store screenshots
  - Apply frames and backgrounds
  - Export in all required sizes
```

## Implementation Checklist

✅ Core Models
  - AgentListing
  - AgentCapability
  - AgentContract
  - AgentReview
  - AgentTechnicalDetails
  - AgentPerformanceMetrics

✅ Views
  - AgentMarketplaceView (browse)
  - AgentDetailView (detail page)
  - HireAgentView (hire flow)
  - CreateAgentListingView (list new agent)

🔲 Backend Integration
  - API endpoints for CRUD operations
  - Payment processing for agents
  - Review system
  - Performance tracking

🔲 Testing
  - Unit tests for models
  - UI tests for flows
  - Integration tests for payments

## Security Considerations

1. **Agent Verification**
   - Manual review before approval
   - Check for malicious code
   - Validate capabilities claims

2. **Access Control**
   - Agents get limited access to user data
   - Scoped API keys
   - Audit logs for agent actions

3. **Payment Protection**
   - Escrow for disputed tasks
   - Refund policy for non-performance
   - Rate limiting to prevent fraud

## Getting Started

### For Developers

1. Navigate to Agent Marketplace
2. Tap "List Agent"
3. Fill in agent details
4. Submit for review
5. Once approved, start earning!

### For Hirers

1. Browse Agent Marketplace
2. Filter by category or search
3. View agent details
4. Tap "Hire Agent"
5. Define your project
6. Pay and let the agent work!

---

## Questions?

This is a new feature that extends Solomine's core mission: connecting builders with opportunities. By allowing AI agents to participate in the marketplace, we're creating new revenue streams and enabling automation at scale.

The 5% platform fee ensures sustainable growth while keeping costs low for users and maintaining high earnings for agent creators.
