//
//  EnhancedChatView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI
import UniformTypeIdentifiers
import PhotosUI

/// Enhanced chat view with file attachment support
struct EnhancedChatView: View {
    let conversation: Conversation
    @StateObject private var chatManager = ChatManager.shared
    @StateObject private var fileManager = FileAttachmentManager.shared
    @State private var messageText = ""
    @State private var showingFilePicker = false
    @State private var showingImagePicker = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var pendingAttachments: [MessageAttachment] = []
    @State private var isUploading = false
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
                messagesScrollView
                
                // Pending Attachments Preview
                if !pendingAttachments.isEmpty {
                    pendingAttachmentsPreview
                }
                
                // Input Area
                chatInput
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            chatManager.loadMessages(for: conversation.id)
        }
        .sheet(isPresented: $showingFilePicker) {
            DocumentPicker(
                allowedTypes: [.pdf, .plainText, .image, .movie, .audio],
                onFilesPicked: { urls in
                    handleFilePicked(urls: urls)
                }
            )
        }
        .photosPicker(
            isPresented: $showingImagePicker,
            selection: $selectedPhotos,
            maxSelectionCount: 5,
            matching: .images
        )
        .onChange(of: selectedPhotos) { _, newPhotos in
            handlePhotoPicked(photos: newPhotos)
        }
        .alert("Upload Error", isPresented: .constant(fileManager.uploadError != nil)) {
            Button("OK") {
                fileManager.uploadError = nil
            }
        } message: {
            if let error = fileManager.uploadError {
                Text(error)
            }
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
    
    // MARK: - Messages Scroll View
    
    private var messagesScrollView: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.md) {
                ForEach(chatManager.activeConversationMessages) { message in
                    EnhancedChatMessageBubble(
                        message: message,
                        isFromCurrentUser: message.senderId == MockData.shared.currentUserId
                    )
                }
            }
            .padding(Theme.Spacing.md)
        }
    }
    
    // MARK: - Pending Attachments Preview
    
    private var pendingAttachmentsPreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(pendingAttachments) { attachment in
                    PendingAttachmentCard(attachment: attachment) {
                        pendingAttachments.removeAll { $0.id == attachment.id }
                    }
                }
            }
            .padding(Theme.Spacing.md)
        }
        .background(Theme.Colors.surface)
    }
    
    // MARK: - Chat Input
    
    private var chatInput: some View {
        VStack(spacing: 0) {
            Divider().background(Theme.Colors.border)
            
            HStack(alignment: .bottom, spacing: Theme.Spacing.sm) {
                // Attachment button
                Menu {
                    Button {
                        showingImagePicker = true
                    } label: {
                        Label("Photos", systemImage: "photo")
                    }
                    
                    Button {
                        showingFilePicker = true
                    } label: {
                        Label("Files", systemImage: "doc")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Theme.Colors.accent)
                }
                .disabled(isUploading)
                
                // Text input
                ZStack(alignment: .topLeading) {
                    if messageText.isEmpty {
                        Text("message...")
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
                
                // Send button
                Button(action: sendMessage) {
                    if isUploading {
                        ProgressView()
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(canSend ? Theme.Colors.accent : Theme.Colors.textSecondary)
                    }
                }
                .disabled(!canSend || isUploading)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.backgroundElevated)
        }
    }
    
    private var canSend: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !pendingAttachments.isEmpty
    }
    
    // MARK: - Actions
    
    private func sendMessage() {
        let content = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard canSend else { return }
        
        Task {
            do {
                try await chatManager.sendMessage(
                    content: content.isEmpty ? "📎 Sent attachments" : content,
                    to: conversation.id,
                    attachments: pendingAttachments
                )
                messageText = ""
                pendingAttachments = []
                isInputFocused = false
            } catch {
                print("Failed to send message: \(error)")
            }
        }
    }
    
    private func handleFilePicked(urls: [URL]) {
        isUploading = true
        
        Task {
            do {
                let attachments = try await fileManager.uploadFiles(from: urls)
                pendingAttachments.append(contentsOf: attachments)
            } catch {
                fileManager.uploadError = error.localizedDescription
            }
            isUploading = false
        }
    }
    
    private func handlePhotoPicked(photos: [PhotosPickerItem]) {
        isUploading = true
        
        Task {
            for photo in photos {
                if let data = try? await photo.loadTransferable(type: Data.self) {
                    // Save to temp directory
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
                    try? data.write(to: tempURL)
                    
                    // Upload
                    if let attachment = try? await fileManager.uploadFile(from: tempURL) {
                        pendingAttachments.append(attachment)
                    }
                }
            }
            
            selectedPhotos = []
            isUploading = false
        }
    }
}

// MARK: - Enhanced Message Bubble

struct EnhancedChatMessageBubble: View {
    let message: ChatMessage
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: Theme.Spacing.xs) {
                // Attachments
                if !message.attachments.isEmpty {
                    ForEach(message.attachments) { attachment in
                        FileAttachmentBubble(attachment: attachment, isFromCurrentUser: isFromCurrentUser)
                    }
                }
                
                // Text content
                if !message.content.isEmpty {
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

// MARK: - File Attachment Bubble

struct FileAttachmentBubble: View {
    let attachment: MessageAttachment
    let isFromCurrentUser: Bool
    @StateObject private var fileManager = FileAttachmentManager.shared
    @State private var isDownloading = false
    
    var body: some View {
        Button {
            downloadAndOpen()
        } label: {
            HStack(spacing: Theme.Spacing.sm) {
                // File icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(FileAttachmentManager.colorForFileType(attachment.mimeType).opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: FileAttachmentManager.iconForFileType(attachment.mimeType))
                        .font(.title3)
                        .foregroundColor(FileAttachmentManager.colorForFileType(attachment.mimeType))
                }
                
                // File info
                VStack(alignment: .leading, spacing: 2) {
                    Text(attachment.fileName)
                        .font(Theme.Typography.small.weight(.semibold))
                        .foregroundColor(isFromCurrentUser ? Theme.Colors.background : Theme.Colors.textPrimary)
                        .lineLimit(2)
                    
                    HStack(spacing: 4) {
                        Text(FileAttachmentManager.formatFileSize(attachment.fileSize))
                            .font(Theme.Typography.tiny)
                            .foregroundColor(isFromCurrentUser ? Theme.Colors.background.opacity(0.7) : Theme.Colors.textSecondary)
                        
                        if isDownloading, let progress = fileManager.downloadProgress[attachment.id] {
                            Text("• \(Int(progress * 100))%")
                                .font(Theme.Typography.tiny)
                                .foregroundColor(isFromCurrentUser ? Theme.Colors.background.opacity(0.7) : Theme.Colors.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                // Download icon
                if isDownloading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.down.circle")
                        .foregroundColor(isFromCurrentUser ? Theme.Colors.background : Theme.Colors.accent)
                }
            }
            .padding(Theme.Spacing.sm)
            .background(isFromCurrentUser ? Theme.Colors.accent : Theme.Colors.surface)
            .cornerRadius(Theme.CornerRadius.medium)
        }
        .buttonStyle(.plain)
    }
    
    private func downloadAndOpen() {
        isDownloading = true
        
        Task {
            do {
                let localURL = try await fileManager.downloadFile(attachment: attachment)
                // Open file with QuickLook or share sheet
                openFile(url: localURL)
            } catch {
                print("Download failed: \(error)")
            }
            isDownloading = false
        }
    }
    
    private func openFile(url: URL) {
        // In production: Use QuickLook or share sheet to open file
        print("Opening file: \(url)")
    }
}

// MARK: - Pending Attachment Card

struct PendingAttachmentCard: View {
    let attachment: MessageAttachment
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            ZStack(alignment: .topTrailing) {
                // File icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(FileAttachmentManager.colorForFileType(attachment.mimeType).opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: FileAttachmentManager.iconForFileType(attachment.mimeType))
                        .font(.largeTitle)
                        .foregroundColor(FileAttachmentManager.colorForFileType(attachment.mimeType))
                }
                
                // Remove button
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .background(Circle().fill(Theme.Colors.background))
                }
                .offset(x: 8, y: -8)
            }
            
            Text(attachment.fileName)
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 80)
            
            Text(FileAttachmentManager.formatFileSize(attachment.fileSize))
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    let allowedTypes: [UTType]
    let onFilesPicked: ([URL]) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onFilesPicked: onFilesPicked)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onFilesPicked: ([URL]) -> Void
        
        init(onFilesPicked: @escaping ([URL]) -> Void) {
            self.onFilesPicked = onFilesPicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onFilesPicked(urls)
        }
    }
}

#Preview {
    NavigationStack {
        EnhancedChatView(conversation: MockData.shared.sampleConversations.first!)
    }
}
