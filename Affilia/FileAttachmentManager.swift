//
//  FileAttachmentManager.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
internal import Combine

/// Manages file uploads, downloads, and storage for chat attachments
@MainActor
class FileAttachmentManager: ObservableObject {
    static let shared = FileAttachmentManager()
    
    @Published var uploadProgress: [UUID: Double] = [:]
    @Published var downloadProgress: [UUID: Double] = [:]
    @Published var uploadError: String?
    
    // Maximum file size (50MB)
    private let maxFileSize: Int64 = 50 * 1024 * 1024
    
    // Allowed file types
    private let allowedFileTypes: Set<String> = [
        "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx",
        "txt", "rtf", "zip", "rar",
        "jpg", "jpeg", "png", "gif", "heic",
        "mp4", "mov", "avi",
        "mp3", "m4a", "wav",
        "sketch", "fig", "psd", "ai",
        "swift", "py", "js", "html", "css", "json"
    ]
    
    private init() {}
    
    // MARK: - File Upload
    
    /// Upload a file and return the MessageAttachment
    func uploadFile(from url: URL) async throws -> MessageAttachment {
        // Validate file
        try validateFile(url: url)
        
        // Get file info
        let fileName = url.lastPathComponent
        let fileSize = try getFileSize(url: url)
        let mimeType = getMimeType(for: url)
        
        // Generate attachment ID
        let attachmentId = UUID()
        
        // Start upload progress tracking
        uploadProgress[attachmentId] = 0.0
        
        // Simulate upload (in production, upload to your backend/S3/etc.)
        let uploadedURL = try await performUpload(url: url, attachmentId: attachmentId)
        
        // Generate thumbnail if it's an image
        let thumbnailURL = try? await generateThumbnail(for: url, attachmentId: attachmentId)
        
        // Remove from progress tracking
        uploadProgress.removeValue(forKey: attachmentId)
        
        return MessageAttachment(
            id: attachmentId,
            fileName: fileName,
            fileSize: fileSize,
            mimeType: mimeType,
            url: uploadedURL,
            thumbnailURL: thumbnailURL
        )
    }
    
    /// Upload multiple files
    func uploadFiles(from urls: [URL]) async throws -> [MessageAttachment] {
        var attachments: [MessageAttachment] = []
        
        for url in urls {
            do {
                let attachment = try await uploadFile(from: url)
                attachments.append(attachment)
            } catch {
                print("Failed to upload \(url.lastPathComponent): \(error)")
                throw error
            }
        }
        
        return attachments
    }
    
    // MARK: - File Download
    
    /// Download a file attachment
    func downloadFile(attachment: MessageAttachment) async throws -> URL {
        // Check if already cached
        if let cachedURL = getCachedFile(for: attachment.id) {
            return cachedURL
        }
        
        // Start download progress
        downloadProgress[attachment.id] = 0.0
        
        // Simulate download (in production, download from your backend)
        let localURL = try await performDownload(attachment: attachment)
        
        // Remove from progress
        downloadProgress.removeValue(forKey: attachment.id)
        
        return localURL
    }
    
    // MARK: - Validation
    
    private func validateFile(url: URL) throws {
        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw FileAttachmentError.fileNotFound
        }
        
        // Check file size
        let fileSize = try getFileSize(url: url)
        guard fileSize <= maxFileSize else {
            throw FileAttachmentError.fileTooLarge(maxSize: maxFileSize)
        }
        
        // Check file type
        let ext = url.pathExtension.lowercased()
        guard allowedFileTypes.contains(ext) else {
            throw FileAttachmentError.fileTypeNotAllowed(extension: ext)
        }
        
        // Security: Check for path traversal
        guard !url.path.contains("..") else {
            throw FileAttachmentError.invalidFilePath
        }
    }
    
    private func getFileSize(url: URL) throws -> Int64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        return attributes[.size] as? Int64 ?? 0
    }
    
    // MARK: - MIME Type Detection
    
    private func getMimeType(for url: URL) -> String {
        let ext = url.pathExtension.lowercased()
        
        // Common types
        switch ext {
        // Documents
        case "pdf": return "application/pdf"
        case "doc": return "application/msword"
        case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "xls": return "application/vnd.ms-excel"
        case "xlsx": return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "ppt": return "application/vnd.ms-powerpoint"
        case "pptx": return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case "txt": return "text/plain"
        case "rtf": return "application/rtf"
        
        // Archives
        case "zip": return "application/zip"
        case "rar": return "application/x-rar-compressed"
        
        // Images
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "gif": return "image/gif"
        case "heic": return "image/heic"
        case "svg": return "image/svg+xml"
        
        // Videos
        case "mp4": return "video/mp4"
        case "mov": return "video/quicktime"
        case "avi": return "video/x-msvideo"
        
        // Audio
        case "mp3": return "audio/mpeg"
        case "m4a": return "audio/mp4"
        case "wav": return "audio/wav"
        
        // Design files
        case "sketch": return "application/sketch"
        case "fig": return "application/figma"
        case "psd": return "image/vnd.adobe.photoshop"
        case "ai": return "application/postscript"
        
        // Code files
        case "swift": return "text/x-swift"
        case "py": return "text/x-python"
        case "js": return "text/javascript"
        case "html": return "text/html"
        case "css": return "text/css"
        case "json": return "application/json"
        
        default: return "application/octet-stream"
        }
    }
    
    // MARK: - Upload/Download Simulation
    
    private func performUpload(url: URL, attachmentId: UUID) async throws -> String {
        // In production: Upload to your backend/S3/Firebase Storage
        // For now, simulate upload with progress
        
        for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
            uploadProgress[attachmentId] = progress
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        // Return mock URL (in production, return the actual uploaded URL)
        return "https://affilia-storage.com/files/\(attachmentId.uuidString)/\(url.lastPathComponent)"
    }
    
    private func performDownload(attachment: MessageAttachment) async throws -> URL {
        // In production: Download from your backend
        // For now, simulate download with progress
        
        for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
            downloadProgress[attachment.id] = progress
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        // Return cached file path
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let cachedPath = documentsPath.appendingPathComponent("attachments/\(attachment.id.uuidString)/\(attachment.fileName)")
        
        // Create directory if needed
        try FileManager.default.createDirectory(
            at: cachedPath.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        
        return cachedPath
    }
    
    // MARK: - Thumbnail Generation
    
    private func generateThumbnail(for url: URL, attachmentId: UUID) async throws -> String? {
        let ext = url.pathExtension.lowercased()
        
        // Only generate thumbnails for images
        guard ["jpg", "jpeg", "png", "heic"].contains(ext) else {
            return nil
        }
        
        // In production: Generate actual thumbnail
        // Return thumbnail URL
        return "https://affilia-storage.com/thumbnails/\(attachmentId.uuidString).jpg"
    }
    
    // MARK: - Caching
    
    private func getCachedFile(for attachmentId: UUID) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let cachedPath = documentsPath.appendingPathComponent("attachments/\(attachmentId.uuidString)")
        
        guard FileManager.default.fileExists(atPath: cachedPath.path) else {
            return nil
        }
        
        return cachedPath
    }
    
    // MARK: - Utilities
    
    /// Format file size for display
    nonisolated static func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    /// Get icon for file type
    static func iconForFileType(_ mimeType: String) -> String {
        if mimeType.hasPrefix("image/") {
            return "photo"
        } else if mimeType.hasPrefix("video/") {
            return "video"
        } else if mimeType.hasPrefix("audio/") {
            return "music.note"
        } else if mimeType.contains("pdf") {
            return "doc.text"
        } else if mimeType.contains("word") || mimeType.contains("document") {
            return "doc.text.fill"
        } else if mimeType.contains("excel") || mimeType.contains("spreadsheet") {
            return "tablecells"
        } else if mimeType.contains("powerpoint") || mimeType.contains("presentation") {
            return "rectangle.on.rectangle"
        } else if mimeType.contains("zip") || mimeType.contains("rar") || mimeType.contains("compressed") {
            return "doc.zipper"
        } else if mimeType.hasPrefix("text/") || mimeType.contains("code") {
            return "chevron.left.forwardslash.chevron.right"
        } else {
            return "doc"
        }
    }
    
    /// Get color for file type
    static func colorForFileType(_ mimeType: String) -> Color {
        if mimeType.hasPrefix("image/") {
            return .blue
        } else if mimeType.hasPrefix("video/") {
            return .purple
        } else if mimeType.hasPrefix("audio/") {
            return .pink
        } else if mimeType.contains("pdf") {
            return .red
        } else if mimeType.contains("word") {
            return Color(hex: "2B579A")
        } else if mimeType.contains("excel") {
            return Color(hex: "217346")
        } else if mimeType.contains("powerpoint") {
            return Color(hex: "D24726")
        } else if mimeType.contains("zip") || mimeType.contains("compressed") {
            return Color(hex: "FFD700")
        } else if mimeType.hasPrefix("text/") {
            return Theme.Colors.accent
        } else {
            return Theme.Colors.textSecondary
        }
    }
}

// MARK: - Errors

enum FileAttachmentError: LocalizedError {
    case fileNotFound
    case fileTooLarge(maxSize: Int64)
    case fileTypeNotAllowed(extension: String)
    case invalidFilePath
    case uploadFailed(Error)
    case downloadFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "File not found"
        case .fileTooLarge(let maxSize):
            return "File is too large. Maximum size is \(FileAttachmentManager.formatFileSize(maxSize))"
        case .fileTypeNotAllowed(let ext):
            return "File type '.\(ext)' is not allowed"
        case .invalidFilePath:
            return "Invalid file path"
        case .uploadFailed(let error):
            return "Upload failed: \(error.localizedDescription)"
        case .downloadFailed(let error):
            return "Download failed: \(error.localizedDescription)"
        }
    }
}
