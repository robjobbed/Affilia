# Contract Management System - Implementation Guide

## Overview

The contract management system allows **builders (freelancers)** to create, send, and manage contracts with clients, who can then pay via **Apple Pay**. The system includes:

- ✅ Contract creation with all necessary fields
- ✅ Multiple payment structures (upfront, milestones, after completion)
- ✅ Apple Pay integration for secure payments
- ✅ Milestone tracking and payment requests
- ✅ Payment links for clients
- ✅ Automatic platform fee calculation (5%)

## Features Implemented

### 1. Builder Contracts View (`BuilderContractsView.swift`)

Located in the **Contracts tab** of the Builder Dashboard, this view provides:

- **Contract List**: Display all contracts with filtering options (All, Pending, Active, Completed, Drafts)
- **Status Badges**: Visual indicators for contract status
- **Milestone Progress**: Progress bars for milestone-based contracts
- **Create Contract Button**: Quick access to create new contracts
- **Empty State**: Helpful guidance when no contracts exist

**Usage:**
```swift
// Automatically displayed in FreelancerDashboardView when user selects Contracts tab
BuilderContractsView()
```

### 2. Builder Create Contract View (`BuilderCreateContractView.swift`)

Comprehensive contract creation form including:

**Required Fields:**
- ✅ Client Selection (from existing clients or contacts)
- ✅ Project Title
- ✅ Project Description
- ✅ Start and End Dates
- ✅ Deliverables (multiple, editable list)
- ✅ Total Contract Value
- ✅ Payment Structure Selection

**Payment Structure Options:**
1. **Pay 100% Upfront**: Full payment before work begins
2. **Pay in Milestones**: Custom milestone percentages (must total 100%)
3. **Pay After Completion**: Payment after delivery (client pays extra 5% fee)

**Payment Breakdown Display:**
- Contract value
- Platform fee (5%)
- Builder receives (95% of contract value)
- Client pays (total amount)

**Usage:**
```swift
BuilderCreateContractView { contract in
    // Handle created contract
    print("Contract created: \(contract.projectTitle)")
}
```

### 3. Contract Details View (`ContractDetailsView.swift`)

Detailed contract view with management capabilities:

**Features:**
- Status banner with current contract status
- Full contract information display
- Payment breakdown
- Milestone list with individual status tracking
- Payment request functionality
- Copyable payment link
- Contract actions (mark complete, report issue, cancel)

**Payment Actions:**
- Send payment request to client
- Request milestone payments
- Generate and share payment links

**Usage:**
```swift
ContractDetailsView(
    contract: myContract,
    onStatusUpdate: { updatedContract in
        // Handle contract updates
    }
)
```

### 4. Client Payment View (`ClientPaymentView.swift`)

Client-facing view for completing payments via Apple Pay:

**Features:**
- Clear payment amount display
- Contract details summary
- Payment breakdown
- Apple Pay button integration
- Secure payment processing
- Success/failure handling

**Payment Flow:**
1. Client clicks payment link from builder
2. Opens ClientPaymentView with contract details
3. Reviews payment breakdown
4. Taps "Pay with Apple Pay"
5. Completes payment via Apple Pay sheet
6. Receives confirmation

**Usage:**
```swift
ClientPaymentView(
    contract: contract,
    milestone: optionalMilestone,
    onPaymentComplete: {
        // Handle successful payment
    }
)
```

### 5. Enhanced Payment Manager (`PaymentManager.swift`)

**New Methods:**

```swift
// Create payment request for a contract
func createContractPaymentRequest(
    contract: Contract,
    milestone: Milestone? = nil
) -> PKPaymentRequest

// Process contract payment via Apple Pay
func processContractPayment(
    contract: Contract,
    milestone: Milestone? = nil,
    completion: @escaping (Result<PKPaymentToken, Error>) -> Void
)
```

## Data Models

### Contract
```swift
struct Contract {
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
    
    // Computed properties
    var platformFee: Double // 5% of total
    var freelancerAmount: Double // 95% of total
    var hirerTotalCost: Double // Varies based on payment structure
}
```

### Payment Structure Options
```swift
enum PaymentStructure {
    case upfront // 100% upfront payment
    case afterCompletion // 100% after completion (hirer pays extra 5%)
    case milestones([MilestonePercentage]) // Custom milestone percentages
}
```

### Contract Status
```swift
enum ContractStatus {
    case draft // Being created
    case pendingSignature // Sent to client, awaiting payment
    case active // Payment received, work in progress
    case completed // All milestones completed
    case disputed // Under dispute
    case cancelled // Cancelled by either party
}
```

### Milestone
```swift
struct Milestone {
    let id: UUID
    let contractId: UUID
    let title: String
    let description: String
    let amount: Double
    let percentage: Double
    let order: Int
    var status: MilestoneStatus
    var completedAt: Date?
    var paidAt: Date?
    var paymentId: String?
}
```

## Apple Pay Integration

### Setup Requirements

1. **Apple Developer Account**
   - Enable Apple Pay capability
   - Create merchant identifier: `merchant.com.affilia.payments`
   - Configure payment processing certificates

2. **Xcode Configuration**
   - Add Apple Pay entitlement
   - Add merchant ID to entitlements file

3. **Info.plist**
   - No special keys required for Apple Pay

### Payment Flow

```swift
// 1. Builder creates contract
let contract = Contract(...)

// 2. Builder sends payment request to client
// Generates link: https://affilia.app/pay/{contractId}

// 3. Client opens link and sees ClientPaymentView

// 4. Client taps "Pay with Apple Pay"
paymentManager.processContractPayment(contract: contract) { result in
    switch result {
    case .success(let token):
        // Send token to backend for processing
        // Backend charges customer and transfers funds
    case .failure(let error):
        // Handle error
    }
}

// 5. Backend processes payment
// - Validates payment token
// - Charges customer via payment processor
// - Deducts 5% platform fee
// - Transfers 95% to builder's account
// - Updates contract status to .active

// 6. Builder receives notification of payment
```

### Payment Security

- ✅ **Apple Pay**: Payments processed securely via Apple's payment system
- ✅ **No Card Storage**: Card details never touch your app or servers
- ✅ **Tokenization**: Payment tokens used instead of actual card data
- ✅ **3D Secure**: Additional authentication for card transactions
- ✅ **Biometric Auth**: Face ID/Touch ID required to authorize payments

## Platform Fee Structure

### Fee Calculation

**Standard (Upfront or Milestones):**
- Contract Value: $50,000
- Platform Fee (5%): $2,500
- Builder Receives: $47,500
- Client Pays: $50,000

**After Completion:**
- Contract Value: $50,000
- Platform Fee (5%): $2,500
- Builder Receives: $47,500
- Client Pays: $52,500 (includes extra 5% to cover builder's fee)

### Why Different?

- **Upfront/Milestones**: Fee deducted from contract value
- **After Completion**: Client pays fee to reduce builder risk

## Usage Examples

### Creating a Contract

```swift
// 1. Builder opens Contracts tab in dashboard
// 2. Taps "Create Contract" button
// 3. Fills out form:
//    - Selects client
//    - Enters project details
//    - Adds deliverables
//    - Sets contract value: $50,000
//    - Chooses payment structure: "Pay in Milestones"
//    - Configures 2 milestones:
//      * 50% - Initial payment ($25,000)
//      * 50% - Final payment ($25,000)
// 4. Reviews payment breakdown
// 5. Taps "Create & Send Contract"
// 6. Contract created with status: .pendingSignature
```

### Requesting Payment

```swift
// Method 1: Send payment request
contract.status == .pendingSignature
// Builder taps "Send Payment Request"
// Client receives notification with payment link

// Method 2: Share payment link
let link = "https://affilia.app/pay/\(contract.id)"
// Builder copies link and sends via email/message
// Client opens link and completes payment

// Method 3: Milestone payment
contract.status == .active
// Builder completes milestone work
// Builder taps "Request Milestone Payment"
// Client receives notification for that milestone
// Client pays via Apple Pay
```

### Processing Payment (Client Side)

```swift
// Client opens payment link
ClientPaymentView(contract: contract) {
    // Payment completed successfully
    
    // Backend has:
    // - Processed payment token
    // - Charged client's payment method
    // - Held funds in escrow (or transferred to builder)
    // - Updated contract status
    // - Sent notifications to both parties
}
```

## Backend Integration

### Required API Endpoints

```
POST /api/contracts
- Create new contract
- Returns: Contract ID and payment link

POST /api/contracts/{id}/send-payment-request
- Sends payment request notification to client
- Generates secure payment link

POST /api/contracts/{id}/process-payment
- Processes Apple Pay payment token
- Charges client
- Transfers funds to builder
- Updates contract status

POST /api/contracts/{id}/milestones/{milestoneId}/request-payment
- Request payment for specific milestone

PATCH /api/contracts/{id}/status
- Update contract status
- Mark milestones as complete

GET /api/contracts
- Fetch all contracts for user
- Filter by status
```

### Payment Processing Backend

```swift
// Pseudo-code for backend payment processing

func processPayment(token: PKPaymentToken, contract: Contract) async throws {
    // 1. Validate payment token
    guard validateToken(token) else {
        throw PaymentError.invalidToken
    }
    
    // 2. Charge customer via payment processor (Stripe, etc.)
    let charge = try await paymentProcessor.charge(
        token: token,
        amount: contract.hirerTotalCost
    )
    
    // 3. Calculate amounts
    let platformFee = contract.platformFee
    let builderAmount = contract.freelancerAmount
    
    // 4. Hold in escrow or transfer immediately
    if contract.paymentStructure == .upfront {
        // Transfer to builder immediately (minus fee)
        try await transferToBuilder(
            builderId: contract.freelancerId,
            amount: builderAmount
        )
    } else {
        // Hold in escrow until milestone completion
        try await escrow.hold(
            contractId: contract.id,
            amount: charge.amount
        )
    }
    
    // 5. Update contract status
    contract.status = .active
    contract.signedByHirer = true
    contract.signedAt = Date()
    
    try await database.update(contract)
    
    // 6. Send notifications
    try await notifications.send(
        to: contract.freelancerId,
        message: "Payment received for \(contract.projectTitle)"
    )
}
```

## Testing

### Test Scenarios

1. **Create Contract**
   - Test all payment structures
   - Verify milestone percentages must total 100%
   - Test validation for required fields

2. **Apple Pay**
   - Test with Apple Pay enabled
   - Test with Apple Pay disabled
   - Test payment success flow
   - Test payment failure handling

3. **Milestones**
   - Test milestone completion
   - Test milestone payment requests
   - Test progress tracking

4. **Contract Status**
   - Test status transitions
   - Test filtering by status
   - Test status badges display

## Next Steps

### Production Checklist

- [ ] Replace mock merchant ID with production ID
- [ ] Implement backend API endpoints
- [ ] Set up payment processor integration (Stripe, etc.)
- [ ] Configure webhooks for payment events
- [ ] Add contract PDF generation
- [ ] Implement contract signing workflow
- [ ] Add push notifications for payment requests
- [ ] Set up email notifications
- [ ] Add analytics tracking
- [ ] Implement dispute resolution workflow
- [ ] Add refund handling
- [ ] Set up escrow system for milestone payments
- [ ] Add contract templates
- [ ] Implement recurring payments option

### Future Enhancements

- **Smart Contracts**: Blockchain integration for trustless payments
- **Multi-currency**: Support for international payments
- **Crypto Payments**: BTC, ETH, USDC options
- **Auto-release**: Automatic milestone payment after X days
- **Rating System**: Rate clients after contract completion
- **Contract Templates**: Pre-made templates for common projects
- **Invoice Generation**: Automatic invoice creation
- **Tax Reporting**: Annual earnings reports for tax filing

## Support

For implementation questions or issues:
1. Check the inline code comments
2. Review the preview providers for usage examples
3. Test in simulator with Apple Pay sandbox
4. Consult Apple's PassKit documentation

## Summary

You now have a complete contract management system with:
- ✅ Full contract creation workflow
- ✅ Apple Pay payment processing
- ✅ Milestone tracking and management
- ✅ Client payment interface
- ✅ Payment request system
- ✅ Automatic fee calculations
- ✅ Status tracking and filtering

The system is ready for backend integration and can be deployed once you:
1. Configure your merchant ID
2. Implement backend APIs
3. Set up payment processor
4. Test with real Apple Pay cards

Happy building! 🚀
