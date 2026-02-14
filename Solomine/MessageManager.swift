//
//  MessageManager.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import Foundation
import CryptoKit
internal import Combine

/// Manages secure messaging with encryption and content moderation
class MessageManager: ObservableObject {
    
    static let shared = MessageManager()
    
    @Published var conversations: [Conversation] = []
    @Published var activeConversationMessages: [Message] = []
    @Published var typingIndicators: [TypingIndicator] = []
    
    // Security settings
    private let enableEncryption = true
    private let enableContentFiltering = true
    
    private init() {
        loadConversations()
    }
    
    // MARK: - Conversation Management
    
    func loadConversations() {
        // In production: Load from secure backend
        conversations = MockData.shared.sampleConversations
    }
    
    func createConversation(with userId: UUID, userName: String) -> Conversation {
        let conversation = Conversation(
            participantIds: [MockData.shared.currentUserId, userId],
            participantNames: ["You", userName],
            isEncrypted: enableEncryption
        )
        conversations.insert(conversation, at: 0)
        return conversation
    }
    
    func loadMessages(for conversationId: UUID) {
        // In production: Load from secure backend with pagination
        // For now, simulate loading messages
        activeConversationMessages = generateSampleMessages(for: conversationId)
    }
    
    // MARK: - Sending Messages
    
    func sendMessage(
        content: String,
        to conversationId: UUID,
        type: MessageType = .text,
        attachments: [MessageAttachment] = []
    ) async throws {
        
        // 1. Content filtering for security
        guard validateMessageContent(content) else {
            throw MessageError.inappropriateContent
        }
        
        // 2. Sanitize input
        let sanitizedContent = sanitizeContent(content)
        
        // 3. Generate message hash for integrity
        let messageHash = generateMessageHash(content: sanitizedContent)
        
        // 4. Create message
        let message = Message(
            senderId: MockData.shared.currentUserId,
            conversationId: conversationId,
            content: sanitizedContent,
            messageType: type,
            attachments: attachments,
            isEncrypted: enableEncryption,
            messageHash: messageHash
        )
        
        // 5. In production: Encrypt message content before sending
        // let encryptedMessage = try encryptMessage(message)
        
        // 6. Send to backend
        // await sendToBackend(encryptedMessage)
        
        // 7. Update local state
        await MainActor.run {
            activeConversationMessages.append(message)
            updateConversationLastMessage(conversationId: conversationId, message: message)
        }
    }
    
    // MARK: - Payment Requests
    
    func sendPaymentRequest(
        to conversationId: UUID,
        amount: Double,
        description: String,
        deliverables: [String],
        dueDate: Date?
    ) async throws {
        
        // Validate amount
        guard amount > 0 && amount <= 100000 else {
            throw MessageError.invalidPaymentAmount
        }
        
        // Create payment request
        let paymentRequest = PaymentRequest(
            amount: amount,
            description: description,
            deliverables: deliverables,
            dueDate: dueDate
        )
        
        // Create message with payment request
        let content = "Payment request: \(description)"
        let message = Message(
            senderId: MockData.shared.currentUserId,
            conversationId: conversationId,
            content: content,
            messageType: .paymentRequest,
            paymentRequest: paymentRequest,
            isEncrypted: enableEncryption
        )
        
        // Send to backend
        await MainActor.run {
            activeConversationMessages.append(message)
            updateConversationLastMessage(conversationId: conversationId, message: message)
        }
    }
    
    func acceptPaymentRequest(_ paymentRequest: PaymentRequest) async throws {
        // In production: Process payment through secure payment gateway
        // For now, update status
        if let messageIndex = activeConversationMessages.firstIndex(where: {
            $0.paymentRequest?.id == paymentRequest.id
        }) {
            var updatedMessage = activeConversationMessages[messageIndex]
            updatedMessage.paymentRequest?.status = .accepted
            activeConversationMessages[messageIndex] = updatedMessage
        }
    }
    
    // MARK: - Security Features
    
    private func validateMessageContent(_ content: String) -> Bool {
        guard enableContentFiltering else { return true }
        
        // Basic profanity/spam filter
        let lowercased = content.lowercased()
        
        // Prohibited patterns
        let prohibitedPatterns = [
            // Add your content filtering rules
            "http://bit.ly", // Common spam
            "clickhere",
            // Add more patterns as needed
        ]
        
        for pattern in prohibitedPatterns {
            if lowercased.contains(pattern) {
                return false
            }
        }
        
        return true
    }
    
    private func sanitizeContent(_ content: String) -> String {
        // Remove potentially dangerous characters
        var sanitized = content
        
        // Trim whitespace
        sanitized = sanitized.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Limit length
        if sanitized.count > 5000 {
            sanitized = String(sanitized.prefix(5000))
        }
        
        return sanitized
    }
    
    private func generateMessageHash(content: String) -> String {
        let data = Data(content.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - Encryption (Production Implementation)
    
    private func encryptMessage(_ message: Message) throws -> Message {
        // In production, implement end-to-end encryption using:
        // - CryptoKit for encryption
        // - Signal Protocol or similar for key exchange
        // - Secure key storage in Keychain
        
        // Placeholder for production implementation
        let encryptedMessage = message
        // encryptedMessage.content = encrypt(message.content, with: recipientPublicKey)
        return encryptedMessage
    }
    
    private func decryptMessage(_ message: Message) throws -> Message {
        // In production: Decrypt message content
        let decryptedMessage = message
        // decryptedMessage.content = decrypt(message.content, with: privateKey)
        return decryptedMessage
    }
    
    // MARK: - Typing Indicators
    
    func startTyping(in conversationId: UUID) {
        let indicator = TypingIndicator(
            conversationId: conversationId,
            userId: MockData.shared.currentUserId,
            userName: "You"
        )
        
        // In production: Send typing indicator to backend via WebSocket
        typingIndicators.append(indicator)
        
        // Auto-remove after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.stopTyping(indicatorId: indicator.id)
        }
    }
    
    func stopTyping(indicatorId: UUID) {
        typingIndicators.removeAll { $0.id == indicatorId }
    }
    
    // MARK: - Blocking & Reporting
    
    func blockConversation(_ conversationId: UUID) {
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            conversations[index].isBlocked = true
            
            // In production: Report to backend for review
        }
    }
    
    func reportMessage(_ messageId: UUID, reason: ReportReason) async {
        // In production: Send report to moderation system
        print("Message \(messageId) reported for: \(reason.rawValue)")
    }
    
    // MARK: - Helper Methods
    
    private func updateConversationLastMessage(conversationId: UUID, message: Message) {
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            conversations[index].lastMessage = message
            conversations[index].updatedAt = Date()
            
            // Move to top of list
            let conversation = conversations.remove(at: index)
            conversations.insert(conversation, at: 0)
        }
    }
    
    private func generateSampleMessages(for conversationId: UUID) -> [Message] {
        // Sample messages for demo
        return [
            Message(
                senderId: UUID(),
                conversationId: conversationId,
                content: "Hey! Thanks for reaching out. I'd love to help with your project.",
                timestamp: Date().addingTimeInterval(-7200),
                isRead: true
            ),
            Message(
                senderId: MockData.shared.currentUserId,
                conversationId: conversationId,
                content: "Great! I need a SwiftUI app built. Can you handle the full project?",
                timestamp: Date().addingTimeInterval(-7000),
                isRead: true
            ),
            Message(
                senderId: UUID(),
                conversationId: conversationId,
                content: "Absolutely. What's the scope? I can send over a quote after we discuss the details.",
                timestamp: Date().addingTimeInterval(-6800),
                isRead: true
            )
        ]
    }
}

// MARK: - Message Errors

enum MessageError: LocalizedError {
    case inappropriateContent
    case invalidPaymentAmount
    case encryptionFailed
    case networkError
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .inappropriateContent:
            return "Message contains prohibited content"
        case .invalidPaymentAmount:
            return "Payment amount must be between $1 and $100,000"
        case .encryptionFailed:
            return "Failed to encrypt message"
        case .networkError:
            return "Network connection error"
        case .unauthorized:
            return "You don't have permission to send this message"
        }
    }
}

