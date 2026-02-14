//
//  SimpleChatView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct SimpleChatView: View {
    let conversation: Conversation
    @StateObject private var chatManager = ChatManager.shared
    @State private var messageText = ""
    @State private var showingPaymentSheet = false
    @FocusState private var isInputFocused: Bool
    
    var otherParticipantName: String {
        conversation.participantNames.first { $0 != "You" } ?? "User"
    }
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Chat Header
                chatHeader
                
                Divider().background(Theme.Colors.border)
                
                // Messages List
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.md) {
                        ForEach(chatManager.activeConversationMessages) { message in
                            ChatMessageBubble(
                                message: message,
                                isFromCurrentUser: message.senderId == MockData.shared.currentUserId
                            )
                        }
                    }
                    .padding(Theme.Spacing.md)
                }
                
                // Input Area
                chatInput
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            chatManager.loadMessages(for: conversation.id)
        }
    }
    
    // MARK: - Chat Header
    
    private var chatHeader: some View {
        HStack(spacing: Theme.Spacing.sm) {
            AvatarView(displayName: otherParticipantName, size: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(otherParticipantName)
                    .font(Theme.Typography.title)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                if conversation.isEncrypted {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                        Text("encrypted")
                            .font(Theme.Typography.tiny)
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
            }
            
            Spacer()
            
            Menu {
                Button(role: .destructive, action: {
                    chatManager.blockConversation(conversation.id)
                }) {
                    Label("Block User", systemImage: "hand.raised.fill")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 20))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.backgroundElevated)
    }
    
    // MARK: - Chat Input
    
    private var chatInput: some View {
        VStack(spacing: 0) {
            Divider().background(Theme.Colors.border)
            
            HStack(alignment: .bottom, spacing: Theme.Spacing.sm) {
                ZStack(alignment: .topLeading) {
                    if messageText.isEmpty {
                        Text("type message...")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                    
                    TextEditor(text: $messageText)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 36, maxHeight: 120)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .focused($isInputFocused)
                }
                .background(Theme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .stroke(Theme.Colors.border, lineWidth: 1)
                )
                .cornerRadius(Theme.CornerRadius.medium)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(messageText.isEmpty ? Theme.Colors.textSecondary : Theme.Colors.accent)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.backgroundElevated)
        }
    }
    
    private func sendMessage() {
        let content = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        Task {
            do {
                try await chatManager.sendMessage(
                    content: content,
                    to: conversation.id
                )
                messageText = ""
                isInputFocused = false
            } catch {
                print("Failed to send message: \(error)")
            }
        }
    }
}

// MARK: - Chat Message Bubble

struct ChatMessageBubble: View {
    let message: ChatMessage
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: Theme.Spacing.xs) {
                Text(message.content)
                    .font(Theme.Typography.body)
                    .foregroundColor(isFromCurrentUser ? Theme.Colors.background : Theme.Colors.textPrimary)
                    .padding(Theme.Spacing.sm)
                    .background(isFromCurrentUser ? Theme.Colors.accent : Theme.Colors.surface)
                    .cornerRadius(Theme.CornerRadius.medium)
                
                Text(formatTimestamp(message.timestamp))
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            if !isFromCurrentUser {
                Spacer(minLength: 60)
            }
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        ChatView(conversation: MockData.shared.sampleConversations.first!)
    }
}
