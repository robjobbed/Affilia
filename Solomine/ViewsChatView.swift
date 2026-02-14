//
//  ChatView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct ChatView: View {
    let conversation: Conversation
    @StateObject private var messageManager = MessageManager.shared
    @State private var messageText = ""
    @State private var showingPaymentSheet = false
    @State private var scrollProxy: ScrollViewProxy?
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
                
                Divider()
                    .background(Theme.Colors.border)
                
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: Theme.Spacing.md) {
                            ForEach(messageManager.activeConversationMessages) { message in
                                MessageBubble(
                                    message: message,
                                    isFromCurrentUser: message.senderId == MockData.shared.currentUserId,
                                    onAcceptPayment: { request in
                                        Task {
                                            try? await messageManager.acceptPaymentRequest(request)
                                        }
                                    }
                                )
                                .id(message.id)
                            }
                            
                            // Typing indicator
                            if messageManager.typingIndicators.contains(where: { $0.conversationId == conversation.id && $0.userId != MockData.shared.currentUserId }) {
                                TypingIndicatorView()
                            }
                        }
                        .padding(Theme.Spacing.md)
                    }
                    .onAppear {
                        scrollProxy = proxy
                        scrollToBottom()
                    }
                }
                
                // Input Area
                chatInput
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            messageManager.loadMessages(for: conversation.id)
        }
        .sheet(isPresented: $showingPaymentSheet) {
            PaymentRequestSheet(
                conversation: conversation,
                onSend: { amount, description, deliverables, dueDate in
                    Task {
                        try? await messageManager.sendPaymentRequest(
                            to: conversation.id,
                            amount: amount,
                            description: description,
                            deliverables: deliverables,
                            dueDate: dueDate
                        )
                        showingPaymentSheet = false
                        scrollToBottom()
                    }
                }
            )
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
                        Text("end-to-end encrypted")
                            .font(Theme.Typography.tiny)
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: Theme.Spacing.sm) {
                Button(action: {
                    showingPaymentSheet = true
                }) {
                    Image(systemName: "dollarsign.circle")
                        .font(.system(size: 20, weight: .regular, design: .monospaced))
                        .foregroundColor(Theme.Colors.accent)
                }
                
                Menu {
                    Button(role: .destructive, action: {
                        messageManager.blockConversation(conversation.id)
                    }) {
                        Label("Block User", systemImage: "hand.raised.fill")
                    }
                    
                    Button(action: {}) {
                        Label("Report Conversation", systemImage: "exclamationmark.triangle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20, weight: .regular, design: .monospaced))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.backgroundElevated)
    }
    
    // MARK: - Chat Input
    
    private var chatInput: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Theme.Colors.border)
            
            HStack(alignment: .bottom, spacing: Theme.Spacing.sm) {
                // Message input
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
                        .onChange(of: messageText) { oldValue, newValue in
                            if !newValue.isEmpty && oldValue.isEmpty {
                                messageManager.startTyping(in: conversation.id)
                            }
                        }
                }
                .background(Theme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .stroke(Theme.Colors.border, lineWidth: 1)
                )
                .cornerRadius(Theme.CornerRadius.medium)
                
                // Send button
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32, weight: .regular, design: .monospaced))
                        .foregroundColor(messageText.isEmpty ? Theme.Colors.textSecondary : Theme.Colors.accent)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.backgroundElevated)
        }
    }
    
    // MARK: - Actions
    
    private func sendMessage() {
        let content = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        Task {
            do {
                try await messageManager.sendMessage(
                    content: content,
                    to: conversation.id
                )
                messageText = ""
                isInputFocused = false
                scrollToBottom()
            } catch {
                // Show error to user
                print("Failed to send message: \(error)")
            }
        }
    }
    
    private func scrollToBottom() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let lastMessage = messageManager.activeConversationMessages.last {
                withAnimation {
                    scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    let onAcceptPayment: (PaymentRequest) -> Void
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: Theme.Spacing.xs) {
                // Message content
                if message.messageType == .paymentRequest, let payment = message.paymentRequest {
                    PaymentRequestCard(
                        paymentRequest: payment,
                        isFromCurrentUser: isFromCurrentUser,
                        onAccept: { onAcceptPayment(payment) }
                    )
                } else {
                    Text(message.content)
                        .font(Theme.Typography.body)
                        .foregroundColor(isFromCurrentUser ? Theme.Colors.background : Theme.Colors.textPrimary)
                        .padding(Theme.Spacing.sm)
                        .background(isFromCurrentUser ? Theme.Colors.accent : Theme.Colors.surface)
                        .cornerRadius(Theme.CornerRadius.medium)
                }
                
                // Timestamp
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

// MARK: - Payment Request Card

struct PaymentRequestCard: View {
    let paymentRequest: PaymentRequest
    let isFromCurrentUser: Bool
    let onAccept: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(Theme.Colors.accent)
                Text("PAYMENT REQUEST")
                    .font(Theme.Typography.caption.weight(.bold))
                    .foregroundColor(Theme.Colors.accent)
                Spacer()
                statusBadge
            }
            
            Divider()
                .background(Theme.Colors.border)
            
            Text(paymentRequest.description)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text("$\(String(format: "%.2f", paymentRequest.amount)) \(paymentRequest.currency)")
                .font(Theme.Typography.heading)
                .foregroundColor(Theme.Colors.accent)
            
            if !paymentRequest.deliverables.isEmpty {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("DELIVERABLES:")
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    ForEach(paymentRequest.deliverables, id: \.self) { deliverable in
                        HStack(spacing: Theme.Spacing.xs) {
                            Text("•")
                            Text(deliverable)
                        }
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textPrimary)
                    }
                }
            }
            
            if !isFromCurrentUser && paymentRequest.status == .pending {
                HStack(spacing: Theme.Spacing.sm) {
                    Button(action: onAccept) {
                        Text("ACCEPT & PAY")
                            .font(Theme.Typography.caption.weight(.bold))
                            .foregroundColor(Theme.Colors.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.sm)
                            .background(Theme.Colors.accent)
                            .cornerRadius(Theme.CornerRadius.medium)
                    }
                    
                    Button(action: {}) {
                        Text("DECLINE")
                            .font(Theme.Typography.caption.weight(.bold))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.sm)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                    .stroke(Theme.Colors.border, lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .stroke(Theme.Colors.accent.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(Theme.CornerRadius.medium)
    }
    
    private var statusBadge: some View {
        Text(paymentRequest.status.rawValue.uppercased())
            .font(Theme.Typography.tiny)
            .foregroundColor(statusColor)
            .padding(.horizontal, Theme.Spacing.xs)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.2))
            .cornerRadius(Theme.CornerRadius.small)
    }
    
    private var statusColor: Color {
        switch paymentRequest.status {
        case .pending: return Theme.Colors.accentSecondary
        case .accepted, .paid: return Theme.Colors.accent
        case .declined, .disputed: return .red
        }
    }
}

// MARK: - Typing Indicator

struct TypingIndicatorView: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Theme.Colors.textSecondary)
                    .frame(width: 6, height: 6)
                    .opacity(animationPhase == index ? 0.4 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: animationPhase
                    )
            }
        }
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xs)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.medium)
        .onAppear {
            animationPhase = 1
        }
    }
}

// MARK: - Payment Request Sheet

struct PaymentRequestSheet: View {
    let conversation: Conversation
    let onSend: (Double, String, [String], Date?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var description = ""
    @State private var deliverables: [String] = [""]
    @State private var includeDueDate = false
    @State private var dueDate = Date().addingTimeInterval(86400 * 7)
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        // Amount
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("AMOUNT (USD)")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            HStack {
                                Text("$")
                                    .font(Theme.Typography.heading)
                                    .foregroundColor(Theme.Colors.accent)
                                TextField("0.00", text: $amount)
                                    .font(Theme.Typography.heading)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                    .keyboardType(.decimalPad)
                            }
                            .padding(Theme.Spacing.sm)
                            .terminalCard()
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("DESCRIPTION")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            TextEditor(text: $description)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textPrimary)
                                .frame(height: 100)
                                .scrollContentBackground(.hidden)
                                .padding(Theme.Spacing.sm)
                                .terminalCard()
                        }
                        
                        // Deliverables
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            HStack {
                                Text("DELIVERABLES")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                Spacer()
                                Button(action: { deliverables.append("") }) {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(Theme.Colors.accent)
                                }
                            }
                            
                            ForEach(deliverables.indices, id: \.self) { index in
                                HStack {
                                    TextField("deliverable \(index + 1)", text: $deliverables[index])
                                        .font(Theme.Typography.body)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                        .padding(Theme.Spacing.sm)
                                        .terminalCard()
                                    
                                    if deliverables.count > 1 {
                                        Button(action: { deliverables.remove(at: index) }) {
                                            Image(systemName: "minus.circle")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Due date
                        Toggle(isOn: $includeDueDate) {
                            Text("INCLUDE DUE DATE")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        .tint(Theme.Colors.accent)
                        
                        if includeDueDate {
                            DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textPrimary)
                        }
                        
                        // Send button
                        Button(action: sendRequest) {
                            Text("SEND PAYMENT REQUEST")
                                .font(Theme.Typography.body.weight(.bold))
                                .foregroundColor(Theme.Colors.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Theme.Spacing.md)
                                .background(Theme.Colors.accent)
                                .cornerRadius(Theme.CornerRadius.medium)
                        }
                        .disabled(!isValid)
                        .opacity(isValid ? 1.0 : 0.5)
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .navigationTitle("Payment Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }
            }
        }
    }
    
    private var isValid: Bool {
        guard let amountValue = Double(amount), amountValue > 0 else { return false }
        guard !description.isEmpty else { return false }
        guard !deliverables.filter({ !$0.isEmpty }).isEmpty else { return false }
        return true
    }
    
    private func sendRequest() {
        guard let amountValue = Double(amount) else { return }
        let validDeliverables = deliverables.filter { !$0.isEmpty }
        
        onSend(
            amountValue,
            description,
            validDeliverables,
            includeDueDate ? dueDate : nil
        )
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ChatView(conversation: MockData.shared.sampleConversations.first!)
    }
}
