//
//  MessagesView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct MessagesView: View {
    @StateObject private var chatManager = ChatManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        // Header
                        TerminalHeader(title: "Messages")
                        
                        // Conversations count
                        Text("> \(chatManager.conversations.count) conversation(s)")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .padding(.horizontal, Theme.Spacing.md)
                        
                        // Conversations list
                        if chatManager.conversations.isEmpty {
                            EmptyStateView(message: "no messages yet. start a conversation_")
                                .padding(.top, Theme.Spacing.xxl)
                        } else {
                            LazyVStack(spacing: Theme.Spacing.md) {
                                ForEach(chatManager.conversations) { conversation in
                                    NavigationLink(destination: ChatView(conversation: conversation)) {
                                        ConversationCard(conversation: conversation)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                        }
                        
                        Spacer(minLength: Theme.Spacing.xl)
                    }
                    .padding(.bottom, Theme.Spacing.md)
                }
            }
        }
    }
}

struct ConversationCard: View {
    let conversation: Conversation
    
    var otherParticipant: String {
        conversation.participantNames.first { $0 != "You" } ?? "Unknown"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            // Header
            HStack {
                Text(otherParticipant)
                    .font(Theme.Typography.title)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                if conversation.unreadCount > 0 {
                    Text("\(conversation.unreadCount)")
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.background)
                        .padding(.horizontal, Theme.Spacing.xs)
                        .padding(.vertical, 2)
                        .background(Theme.Colors.accent)
                        .cornerRadius(Theme.CornerRadius.small)
                }
            }
            
            // Last message
            if let lastMessage = conversation.lastMessage {
                Text(lastMessage.content)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineLimit(2)
                
                HStack {
                    Text(timeAgoString(from: lastMessage.timestamp))
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    Spacer()
                    
                    if !lastMessage.isRead && lastMessage.senderId != MockData.shared.currentUserId {
                        Text("NEW")
                            .font(Theme.Typography.tiny)
                            .foregroundColor(Theme.Colors.accent)
                    }
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(Theme.Colors.accent)
                }
                .padding(.top, Theme.Spacing.xs)
            }
        }
        .padding(Theme.Spacing.md)
        .terminalCard()
    }
    
    func timeAgoString(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        
        if seconds < 60 {
            return "just now"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            return "\(minutes)m ago"
        } else if seconds < 86400 {
            let hours = seconds / 3600
            return "\(hours)h ago"
        } else {
            let days = seconds / 86400
            return "\(days)d ago"
        }
    }
}

#Preview {
    MessagesView()
}
