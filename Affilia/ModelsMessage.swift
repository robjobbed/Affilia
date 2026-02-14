//
//  Message.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//
//  DEPRECATED: This file is replaced by ModelsChatModels.swift
//  These types are commented out to prevent duplicate declarations
//

import Foundation

/*
struct Conversation: Identifiable, Codable {
    let id: UUID
    var participantIds: [UUID]
    var participantNames: [String]
    var lastMessage: Message?
    var unreadCount: Int
    
    init(
        id: UUID = UUID(),
        participantIds: [UUID],
        participantNames: [String],
        lastMessage: Message? = nil,
        unreadCount: Int = 0
    ) {
        self.id = id
        self.participantIds = participantIds
        self.participantNames = participantNames
        self.lastMessage = lastMessage
        self.unreadCount = unreadCount
    }
}

struct Message: Identifiable, Codable {
    let id: UUID
    var senderId: UUID
    var conversationId: UUID
    var content: String
    var timestamp: Date
    var isRead: Bool
    
    init(
        id: UUID = UUID(),
        senderId: UUID,
        conversationId: UUID,
        content: String,
        timestamp: Date = Date(),
        isRead: Bool = false
    ) {
        self.id = id
        self.senderId = senderId
        self.conversationId = conversationId
        self.content = content
        self.timestamp = timestamp
        self.isRead = isRead
    }
}
*/
