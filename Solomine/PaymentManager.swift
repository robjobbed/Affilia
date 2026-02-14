//
//  PaymentManager.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import Foundation
import PassKit
internal import Combine

// MARK: - Payment Models

struct PaymentRecord: Identifiable, Codable {
    let id: UUID
    let transactionId: String
    let amount: Double
    let description: String
    let timestamp: Date
    let status: PaymentStatusType
    
    enum PaymentStatusType: String, Codable {
        case pending
        case completed
        case failed
        case refunded
    }
    
    init(
        id: UUID = UUID(),
        transactionId: String,
        amount: Double,
        description: String,
        timestamp: Date = Date(),
        status: PaymentStatusType = .completed
    ) {
        self.id = id
        self.transactionId = transactionId
        self.amount = amount
        self.description = description
        self.timestamp = timestamp
        self.status = status
    }
}

/// Handles Apple Pay payments for hiring freelancers
class PaymentManager: NSObject, ObservableObject {
    
    static let shared = PaymentManager()
    
    @Published var paymentStatus: PaymentStatus = .idle
    
    enum PaymentStatus {
        case idle
        case processing
        case success
        case failed(Error)
    }
    
    private override init() {
        super.init()
    }
    
    /// Check if Apple Pay is available on this device
    var isApplePayAvailable: Bool {
        return PKPaymentAuthorizationController.canMakePayments()
    }
    
    /// Check if user has cards set up in Apple Pay
    var hasPaymentCards: Bool {
        let networks: [PKPaymentNetwork] = [.visa, .masterCard, .amex, .discover]
        return PKPaymentAuthorizationController.canMakePayments(usingNetworks: networks)
    }
    
    /// Create a payment request for a contract
    func createContractPaymentRequest(
        contract: Contract,
        milestone: Milestone? = nil
    ) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        
        // Configure merchant
        request.merchantIdentifier = "merchant.com.solomine.payments" // Replace with your actual merchant ID
        request.merchantCapabilities = .threeDSecure
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.supportedNetworks = [.visa, .masterCard, .amex, .discover]
        
        // Determine amount based on milestone or full contract
        let paymentAmount: Double
        let paymentLabel: String
        
        if let milestone = milestone {
            paymentAmount = milestone.amount
            paymentLabel = "\(contract.projectTitle) - \(milestone.title)"
        } else {
            paymentAmount = contract.hirerTotalCost
            paymentLabel = contract.projectTitle
        }
        
        // Create payment summary items
        let contractItem = PKPaymentSummaryItem(
            label: paymentLabel,
            amount: NSDecimalNumber(value: paymentAmount),
            type: .final
        )
        
        let platformFee = PKPaymentSummaryItem(
            label: "Platform Fee (5%)",
            amount: NSDecimalNumber(value: contract.platformFee),
            type: .final
        )
        
        let total = PKPaymentSummaryItem(
            label: "Affilia",
            amount: NSDecimalNumber(value: paymentAmount),
            type: .final
        )
        
        request.paymentSummaryItems = [contractItem, platformFee, total]
        
        return request
    }
    
    /// Create a payment request for hiring a freelancer
    func createPaymentRequest(
        freelancer: FreelancerProfile,
        amount: Double,
        description: String
    ) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        
        // Configure merchant
        request.merchantIdentifier = "merchant.com.solomine.payments" // Replace with your actual merchant ID
        request.merchantCapabilities = .threeDSecure
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.supportedNetworks = [.visa, .masterCard, .amex, .discover]
        
        // Create payment summary items
        let freelancerItem = PKPaymentSummaryItem(
            label: "Payment to \(freelancer.handle)",
            amount: NSDecimalNumber(value: amount),
            type: .final
        )
        
        let platformFee = PKPaymentSummaryItem(
            label: "Affilia Platform Fee",
            amount: NSDecimalNumber(value: amount * 0.05), // 5% platform fee
            type: .final
        )
        
        let total = PKPaymentSummaryItem(
            label: "Affilia",
            amount: NSDecimalNumber(value: amount * 1.05),
            type: .final
        )
        
        request.paymentSummaryItems = [freelancerItem, platformFee, total]
        
        return request
    }
    
    /// Process payment for a contract via Apple Pay
    func processContractPayment(
        contract: Contract,
        milestone: Milestone? = nil,
        completion: @escaping (Result<PKPaymentToken, Error>) -> Void
    ) {
        guard isApplePayAvailable else {
            completion(.failure(PaymentError.applePayNotAvailable))
            return
        }
        
        guard hasPaymentCards else {
            completion(.failure(PaymentError.noCardsSetup))
            return
        }
        
        let request = createContractPaymentRequest(
            contract: contract,
            milestone: milestone
        )
        
        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller.delegate = self
        controller.present { presented in
            if !presented {
                completion(.failure(PaymentError.presentationFailed))
            }
        }
        
        // Store completion for delegate callback
        self.pendingCompletion = completion
    }
    
    /// Present Apple Pay sheet for payment
    func processPayment(
        for freelancer: FreelancerProfile,
        amount: Double,
        description: String,
        completion: @escaping (Result<PKPaymentToken, Error>) -> Void
    ) {
        guard isApplePayAvailable else {
            completion(.failure(PaymentError.applePayNotAvailable))
            return
        }
        
        guard hasPaymentCards else {
            completion(.failure(PaymentError.noCardsSetup))
            return
        }
        
        let request = createPaymentRequest(
            freelancer: freelancer,
            amount: amount,
            description: description
        )
        
        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller.delegate = self
        controller.present { presented in
            if !presented {
                completion(.failure(PaymentError.presentationFailed))
            }
        }
        
        // Store completion for delegate callback
        self.pendingCompletion = completion
    }
    
    private var pendingCompletion: ((Result<PKPaymentToken, Error>) -> Void)?
    
    // MARK: - Generic Apple Pay Payment
    
    /// Process a generic Apple Pay payment
    func processApplePayPayment(amount: Double, description: String) async throws -> PaymentRecord {
        guard amount > 0 else {
            throw PaymentError.invalidAmount
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = PKPaymentRequest()
            
            // Configure merchant
            request.merchantIdentifier = "merchant.com.solomine.payments"
            request.merchantCapabilities = .threeDSecure
            request.countryCode = "US"
            request.currencyCode = "USD"
            request.supportedNetworks = [.visa, .masterCard, .amex, .discover]
            
            // Create payment summary items
            let paymentItem = PKPaymentSummaryItem(
                label: description,
                amount: NSDecimalNumber(value: amount),
                type: .final
            )
            
            let total = PKPaymentSummaryItem(
                label: "Affilia",
                amount: NSDecimalNumber(value: amount),
                type: .final
            )
            
            request.paymentSummaryItems = [paymentItem, total]
            
            let controller = PKPaymentAuthorizationController(paymentRequest: request)
            controller.delegate = self
            
            controller.present { [weak self] presented in
                guard presented else {
                    continuation.resume(throwing: PaymentError.presentationFailed)
                    return
                }
                
                // Store continuation to resume in delegate callback
                self?.genericPaymentContinuation = continuation
                self?.paymentAmount = amount
                self?.paymentDescription = description
            }
        }
    }
    
    private var genericPaymentContinuation: CheckedContinuation<PaymentRecord, Error>?
    private var paymentAmount: Double = 0
    private var paymentDescription: String = ""
}

// MARK: - PKPaymentAuthorizationControllerDelegate
extension PaymentManager: PKPaymentAuthorizationControllerDelegate {
    
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        // In production, you would send payment.token to your backend
        // For now, we'll simulate successful payment processing
        
        paymentStatus = .processing
        
        // Simulate backend processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // Here you would normally:
            // 1. Send payment token to your backend
            // 2. Backend processes payment with payment processor
            // 3. Backend returns success/failure
            
            // For now, simulate success
            self.paymentStatus = .success
            self.pendingCompletion?(.success(payment.token))
            
            // If this is a generic payment (for agent hiring), resume continuation
            if let continuation = self.genericPaymentContinuation {
                let paymentRecord = PaymentRecord(
                    transactionId: UUID().uuidString,
                    amount: self.paymentAmount,
                    description: self.paymentDescription,
                    status: .completed
                )
                continuation.resume(returning: paymentRecord)
                self.genericPaymentContinuation = nil
            }
            
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss()
    }
}

// MARK: - Payment Errors
enum PaymentError: LocalizedError {
    case applePayNotAvailable
    case noCardsSetup
    case presentationFailed
    case processingFailed
    case invalidAmount
    
    var errorDescription: String? {
        switch self {
        case .applePayNotAvailable:
            return "Apple Pay is not available on this device"
        case .noCardsSetup:
            return "No payment cards are set up in Apple Pay"
        case .presentationFailed:
            return "Failed to present Apple Pay sheet"
        case .processingFailed:
            return "Payment processing failed"
        case .invalidAmount:
            return "Invalid payment amount"
        }
    }
}
