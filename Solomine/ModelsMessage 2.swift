//
//  Message.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//
//  DEPRECATED: This file has been replaced by ModelsChatModels.swift
//  All types below are commented out to prevent duplicate declarations.
//  Use ChatMessage from ModelsChatModels.swift instead.

import Foundation

/*
// MARK: - Message Models

struct Message: Identifiable, Codable {
    let id: UUID
    let conversationId: UUID
    let senderId: UUID
    let content: String
    let timestamp: Date
    var isRead: Bool
    let messageType: MessageType
    var attachments: [MessageAttachment]
    
    // Payment request data (if applicable)
    var paymentRequest: PaymentRequest?
    
    // Security metadata
    let isEncrypted: Bool
    let messageHash: String? // For integrity verification
    
    init(
        id: UUID = UUID(),
        senderId: UUID,
        conversationId: UUID,
        content: String,
        timestamp: Date = Date(),
        isRead: Bool = false,
        messageType: MessageType = .text,
        attachments: [MessageAttachment] = [],
        paymentRequest: PaymentRequest? = nil,
        isEncrypted: Bool = false,
        messageHash: String? = nil
    ) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.content = content
        self.timestamp = timestamp
        self.isRead = isRead
        self.messageType = messageType
        self.attachments = attachments
        self.paymentRequest = paymentRequest
        self.isEncrypted = isEncrypted
        self.messageHash = messageHash
    }
}

enum MessageType: String, Codable {
    case text
    case paymentRequest
    case paymentConfirmation
    case attachment
    case systemNotification
}

struct MessageAttachment: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let fileSize: Int64
    let mimeType: String
    let url: String // Secure presigned URL in production
    let thumbnailURL: String?
    
    init(
        id: UUID = UUID(),
        fileName: String,
        fileSize: Int64,
        mimeType: String,
        url: String,
        thumbnailURL: String? = nil
    ) {
        self.id = id
        self.fileName = fileName
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.url = url
        self.thumbnailURL = thumbnailURL
    }
}

// MARK: - Payment Request

struct PaymentRequest: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let currency: String
    let description: String
    let deliverables: [String]
    let dueDate: Date?
    var status: PaymentRequestStatus
    let createdAt: Date
    var paidAt: Date?
    
    init(
        id: UUID = UUID(),
        amount: Double,
        currency: String = "USD",
        description: String,
        deliverables: [String],
        dueDate: Date? = nil,
        status: PaymentRequestStatus = .pending,
        createdAt: Date = Date(),
        paidAt: Date? = nil
    ) {
        self.id = id
        self.amount = amount
        self.currency = currency
        self.description = description
        self.deliverables = deliverables
        self.dueDate = dueDate
        self.status = status
        self.createdAt = createdAt
        self.paidAt = paidAt
    }
}

enum PaymentRequestStatus: String, Codable {
    case pending
    case accepted
    case declined
    case paid
    case disputed
}

// MARK: - Conversation

struct Conversation: Identifiable, Codable {
    let id: UUID
    let participantIds: [UUID]
    var participantNames: [String]
    var lastMessage: Message?
    var unreadCount: Int
    let createdAt: Date
    var updatedAt: Date
    
    // Security features
    var isEncrypted: Bool
    var isBlocked: Bool // For blocking spam/harassment
    
    init(
        id: UUID = UUID(),
        participantIds: [UUID],
        participantNames: [String],
        lastMessage: Message? = nil,
        unreadCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isEncrypted: Bool = true,
        isBlocked: Bool = false
    ) {
        self.id = id
        self.participantIds = participantIds
        self.participantNames = participantNames
        self.lastMessage = lastMessage
        self.unreadCount = unreadCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isEncrypted = isEncrypted
        self.isBlocked = isBlocked
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: Identifiable {
    let id: UUID
    let conversationId: UUID
    let userId: UUID
    let userName: String
    let timestamp: Date
    
    init(
        id: UUID = UUID(),
        conversationId: UUID,
        userId: UUID,
        userName: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.conversationId = conversationId
        self.userId = userId
        self.userName = userName
        self.timestamp = timestamp
    }
}
*/
