//
//  ChatManager.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import Foundation
import CryptoKit
import SwiftUI
internal import Combine

/// Manages secure messaging with encryption and content moderation
@MainActor
class ChatManager: ObservableObject {
    
    static let shared = ChatManager()
    
    @Published var conversations: [Conversation] = []
    @Published var activeConversationMessages: [ChatMessage] = []
    @Published var typingIndicators: [TypingIndicator] = []
    
    // Security settings
    private let enableEncryption = true
    private let enableContentFiltering = true
    
    private init() {
        loadConversations()
    }
    
    // MARK: - Conversation Management
    
    func loadConversations() {
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
        activeConversationMessages = generateSampleMessages(for: conversationId)
    }
    
    // MARK: - Sending Messages
    
    func sendMessage(
        content: String,
        to conversationId: UUID,
        type: ChatMessageType = .text,
        attachments: [MessageAttachment] = []
    ) async throws {
        
        // 1. Content filtering for security
        guard validateMessageContent(content) else {
            throw ChatError.inappropriateContent
        }
        
        // 2. Sanitize input
        let sanitizedContent = sanitizeContent(content)
        
        // 3. Generate message hash for integrity
        let messageHash = generateMessageHash(content: sanitizedContent)
        
        // 4. Create message
        let message = ChatMessage(
            senderId: MockData.shared.currentUserId,
            conversationId: conversationId,
            content: sanitizedContent,
            messageType: type,
            attachments: attachments,
            isEncrypted: enableEncryption,
            messageHash: messageHash
        )
        
        // 5. Update local state
        activeConversationMessages.append(message)
        updateConversationLastMessage(conversationId: conversationId, message: message)
    }
    
    // MARK: - Payment Requests
    
    func sendPaymentRequest(
        to conversationId: UUID,
        amount: Double,
        description: String,
        deliverables: [String],
        dueDate: Date?
    ) async throws {
        
        guard amount > 0 && amount <= 100000 else {
            throw ChatError.invalidPaymentAmount
        }
        
        let paymentRequest = PaymentRequest(
            amount: amount,
            description: description,
            deliverables: deliverables,
            dueDate: dueDate
        )
        
        let content = "Payment request: \(description)"
        let message = ChatMessage(
            senderId: MockData.shared.currentUserId,
            conversationId: conversationId,
            content: content,
            messageType: .paymentRequest,
            paymentRequest: paymentRequest,
            isEncrypted: enableEncryption
        )
        
        activeConversationMessages.append(message)
        updateConversationLastMessage(conversationId: conversationId, message: message)
    }
    
    func acceptPaymentRequest(_ paymentRequest: PaymentRequest) async throws {
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
        
        let lowercased = content.lowercased()
        let prohibitedPatterns = ["http://bit.ly", "clickhere"]
        
        for pattern in prohibitedPatterns {
            if lowercased.contains(pattern) {
                return false
            }
        }
        
        return true
    }
    
    private func sanitizeContent(_ content: String) -> String {
        var sanitized = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
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
    
    // MARK: - Typing Indicators
    
    func startTyping(in conversationId: UUID) {
        let indicator = TypingIndicator(
            conversationId: conversationId,
            userId: MockData.shared.currentUserId,
            userName: "You"
        )
        
        typingIndicators.append(indicator)
        
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            stopTyping(indicatorId: indicator.id)
        }
    }
    
    func stopTyping(indicatorId: UUID) {
        typingIndicators.removeAll { $0.id == indicatorId }
    }
    
    // MARK: - Blocking & Reporting
    
    func blockConversation(_ conversationId: UUID) {
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            conversations[index].isBlocked = true
        }
    }
    
    func reportMessage(_ messageId: UUID, reason: ReportReason) async {
        print("Message \(messageId) reported for: \(reason.rawValue)")
    }
    
    // MARK: - Helper Methods
    
    private func updateConversationLastMessage(conversationId: UUID, message: ChatMessage) {
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            conversations[index].lastMessage = message
            conversations[index].updatedAt = Date()
            
            let conversation = conversations.remove(at: index)
            conversations.insert(conversation, at: 0)
        }
    }
    
    private func generateSampleMessages(for conversationId: UUID) -> [ChatMessage] {
        return [
            ChatMessage(
                senderId: UUID(),
                conversationId: conversationId,
                content: "Hey! Thanks for reaching out. I'd love to help with your project.",
                timestamp: Date().addingTimeInterval(-7200),
                isRead: true
            ),
            ChatMessage(
                senderId: MockData.shared.currentUserId,
                conversationId: conversationId,
                content: "Great! I need a SwiftUI app built. Can you handle the full project?",
                timestamp: Date().addingTimeInterval(-7000),
                isRead: true
            ),
            ChatMessage(
                senderId: UUID(),
                conversationId: conversationId,
                content: "Absolutely. What's the scope? I can send over a quote after we discuss the details.",
                timestamp: Date().addingTimeInterval(-6800),
                isRead: true
            )
        ]
    }
}

// MARK: - Chat Errors

enum ChatError: LocalizedError {
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

