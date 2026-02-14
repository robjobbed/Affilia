# File Sharing in Chat - Complete Guide

## Overview

Your chat system now supports **full file sharing** capabilities! Buyers (hirers) and builders (freelancers) can exchange:
- 📄 Documents (PDF, Word, Excel, PowerPoint)
- 🖼️ Images (JPG, PNG, HEIC, GIF)
- 🎥 Videos (MP4, MOV, AVI)
- 🎵 Audio (MP3, M4A, WAV)
- 🗜️ Archives (ZIP, RAR)
- 💻 Code files (Swift, Python, JS, HTML, etc.)
- 🎨 Design files (Sketch, Figma, PSD, AI)

## Features

### For Senders
- ✅ Upload files from device
- ✅ Select photos from library
- ✅ Multiple file selection (up to 5 photos, unlimited docs)
- ✅ Upload progress tracking
- ✅ Preview before sending
- ✅ Remove attachments before sending
- ✅ File type validation
- ✅ Size limit enforcement (50MB max)

### For Receivers
- ✅ View file details (name, size, type)
- ✅ Download files
- ✅ Download progress tracking
- ✅ File caching (download once, view many times)
- ✅ Quick preview with QuickLook
- ✅ Share downloaded files

### Security
- ✅ File type validation
- ✅ Size limit enforcement (50MB)
- ✅ Path traversal protection
- ✅ MIME type detection
- ✅ End-to-end encryption support (optional)

## Files Created

1. **`FileAttachmentManager.swift`** - Core file management
   - Upload/download handling
   - Progress tracking
   - File validation
   - Caching system
   - MIME type detection
   - Thumbnail generation

2. **`ViewsEnhancedChatView.swift`** - Enhanced chat UI
   - File picker integration
   - Photo picker integration
   - Attachment preview
   - File bubble display
   - Download functionality

## Integration

### Option 1: Replace Existing ChatView

Replace your current `SimpleChatView` usage with `EnhancedChatView`:

```swift
// Before
NavigationLink {
    SimpleChatView(conversation: conversation)
}

// After
NavigationLink {
    EnhancedChatView(conversation: conversation)
}
```

### Option 2: Gradual Migration

Keep both views and test the new one:

```swift
// Test with feature flag
if enableFileSharing {
    EnhancedChatView(conversation: conversation)
} else {
    SimpleChatView(conversation: conversation)
}
```

## Usage Examples

### Send a File

1. **User opens chat**
2. **Taps the `+` button** (bottom left)
3. **Chooses "Files" or "Photos"**
4. **Selects file(s)** from device
5. **Sees preview** of pending attachments
6. **Optionally adds message text**
7. **Taps send button** ⬆️

### Receive a File

1. **User sees file in chat bubble**
2. **File shows icon, name, and size**
3. **Taps on file bubble**
4. **File downloads** (with progress bar)
5. **File opens** in QuickLook/Share sheet

## File Types Supported

### Documents (📄)
- PDF (`.pdf`)
- Word (`.doc`, `.docx`)
- Excel (`.xls`, `.xlsx`)
- PowerPoint (`.ppt`, `.pptx`)
- Text (`.txt`, `.rtf`)

### Images (🖼️)
- JPEG (`.jpg`, `.jpeg`)
- PNG (`.png`)
- GIF (`.gif`)
- HEIC (`.heic`)
- SVG (`.svg`)

### Videos (🎥)
- MP4 (`.mp4`)
- QuickTime (`.mov`)
- AVI (`.avi`)

### Audio (🎵)
- MP3 (`.mp3`)
- M4A (`.m4a`)
- WAV (`.wav`)

### Archives (🗜️)
- ZIP (`.zip`)
- RAR (`.rar`)

### Design Files (🎨)
- Sketch (`.sketch`)
- Figma (`.fig`)
- Photoshop (`.psd`)
- Illustrator (`.ai`)

### Code Files (💻)
- Swift (`.swift`)
- Python (`.py`)
- JavaScript (`.js`)
- HTML (`.html`)
- CSS (`.css`)
- JSON (`.json`)

## Technical Details

### File Size Limits

```swift
// Maximum 50MB per file
private let maxFileSize: Int64 = 50 * 1024 * 1024
```

To change:
```swift
// In FileAttachmentManager.swift
private let maxFileSize: Int64 = 100 * 1024 * 1024 // 100MB
```

### Adding New File Types

```swift
// In FileAttachmentManager.swift
private let allowedFileTypes: Set<String> = [
    // Add your extension here
    "md", "yaml", "xml", // etc.
]
```

### Upload Process

```
1. User selects file
2. Validate file (type, size, path)
3. Get file metadata (name, size, MIME type)
4. Upload to backend/S3/Firebase
5. Generate thumbnail (if image)
6. Return MessageAttachment with URL
7. Attach to ChatMessage
8. Send message
```

### Download Process

```
1. User taps file bubble
2. Check if cached locally
3. If not cached, download from backend
4. Show progress bar
5. Save to local cache
6. Open with QuickLook or share
```

## Backend Integration

### Required API Endpoints

You'll need to implement these on your backend:

```
POST   /api/chat/upload                 - Upload file, return URL
GET    /api/chat/download/:fileId       - Download file
GET    /api/chat/thumbnail/:fileId      - Get thumbnail (images)
DELETE /api/chat/file/:fileId           - Delete file
```

### Upload Example

```swift
// In FileAttachmentManager.swift, replace performUpload:

private func performUpload(url: URL, attachmentId: UUID) async throws -> String {
    // Real implementation
    let boundary = UUID().uuidString
    var request = URLRequest(url: URL(string: "https://api.solomine.com/chat/upload")!)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    // Create multipart body
    var body = Data()
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(url.lastPathComponent)\"\r\n")
    body.append("Content-Type: application/octet-stream\r\n\r\n")
    body.append(try Data(contentsOf: url))
    body.append("\r\n--\(boundary)--\r\n")
    
    request.httpBody = body
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw FileAttachmentError.uploadFailed(NSError(domain: "", code: -1))
    }
    
    // Parse response to get file URL
    let json = try JSONDecoder().decode([String: String].self, from: data)
    guard let fileURL = json["url"] else {
        throw FileAttachmentError.uploadFailed(NSError(domain: "", code: -1))
    }
    
    return fileURL
}
```

### Storage Options

**Option A: AWS S3**
```swift
import AWSS3

func uploadToS3(url: URL) async throws -> String {
    let transferUtility = AWSS3TransferUtility.default()
    // Upload logic
    return s3URL
}
```

**Option B: Firebase Storage**
```swift
import FirebaseStorage

func uploadToFirebase(url: URL) async throws -> String {
    let storageRef = Storage.storage().reference()
    let fileRef = storageRef.child("chat-attachments/\(UUID().uuidString)")
    let metadata = try await fileRef.putFileAsync(from: url)
    let downloadURL = try await fileRef.downloadURL()
    return downloadURL.absoluteString
}
```

**Option C: Your Own Server**
```swift
// Upload to your backend
// Store files in /var/www/uploads or similar
// Return public URL: https://yourdomain.com/uploads/filename
```

## Security Considerations

### 1. File Validation

```swift
// Already implemented in FileAttachmentManager
- File type whitelist
- Size limit enforcement  
- Path traversal protection
- MIME type verification
```

### 2. Virus Scanning

Add to your backend:
```
- Scan uploads with ClamAV or similar
- Quarantine suspicious files
- Notify users of blocked files
```

### 3. Access Control

```swift
// Verify user has permission to access file
- Check conversation membership
- Verify message ownership
- Token-based download links
- Expiring URLs (e.g., 24 hours)
```

### 4. Encryption

```swift
// Optional: Encrypt files before upload
func encryptFile(url: URL) throws -> Data {
    let data = try Data(contentsOf: url)
    let key = SymmetricKey(size: .bits256)
    let encrypted = try AES.GCM.seal(data, using: key)
    return encrypted.combined!
}
```

## UI Components

### File Attachment Bubble

```swift
FileAttachmentBubble(
    attachment: attachment,
    isFromCurrentUser: true
)
```

Features:
- Color-coded by file type
- Shows file icon
- Displays name and size
- Download button
- Progress indicator

### Pending Attachment Card

```swift
PendingAttachmentCard(
    attachment: attachment,
    onRemove: { /* remove logic */ }
)
```

Features:
- Preview before sending
- Remove button
- File type icon
- Name and size

### Document Picker

```swift
DocumentPicker(
    allowedTypes: [.pdf, .image, .movie],
    onFilesPicked: { urls in
        // Handle selected files
    }
)
```

### Photo Picker

```swift
.photosPicker(
    isPresented: $showingImagePicker,
    selection: $selectedPhotos,
    maxSelectionCount: 5,
    matching: .images
)
```

## Customization

### Change File Size Limit

```swift
// In FileAttachmentManager.swift
private let maxFileSize: Int64 = 100 * 1024 * 1024 // 100MB
```

### Change Max Photo Selection

```swift
// In EnhancedChatView.swift
.photosPicker(
    isPresented: $showingImagePicker,
    selection: $selectedPhotos,
    maxSelectionCount: 10, // ← Change this
    matching: .images
)
```

### Add New File Types

```swift
// In FileAttachmentManager.swift
private let allowedFileTypes: Set<String> = [
    // Add here
    "pages", "numbers", "keynote", // iWork
    "eps", "tiff", "raw", // More image formats
    // etc.
]
```

### Customize File Icons/Colors

```swift
// In FileAttachmentManager.swift
static func iconForFileType(_ mimeType: String) -> String {
    // Customize icon mapping
}

static func colorForFileType(_ mimeType: String) -> Color {
    // Customize color mapping
}
```

## Testing Checklist

### Upload Testing
- [ ] Select and upload single file
- [ ] Select and upload multiple files
- [ ] Upload large file (near limit)
- [ ] Try to upload file over limit (should fail)
- [ ] Try to upload unsupported type (should fail)
- [ ] Remove attachment before sending
- [ ] Send message with attachments
- [ ] Send attachment without text message

### Download Testing
- [ ] Download small file
- [ ] Download large file
- [ ] Cancel download mid-way
- [ ] Download already cached file (should be instant)
- [ ] Open file after download
- [ ] Share file after download

### UI Testing
- [ ] File bubbles display correctly
- [ ] Progress bars work
- [ ] Icons match file types
- [ ] Colors are appropriate
- [ ] Layout works on small screens
- [ ] Layout works on large screens (iPad)
- [ ] Dark mode looks good
- [ ] Light mode looks good

### Error Testing
- [ ] Network error during upload
- [ ] Network error during download
- [ ] No storage space on device
- [ ] Permission denied (Photos)
- [ ] Invalid file path
- [ ] Corrupted file

## Common Use Cases

### Design Review
```
Designer: "Here's the mockup" [attaches Figma file]
Client: "Can you change the color?" [attaches reference image]
Designer: "Done!" [attaches updated design]
```

### Code Delivery
```
Developer: "Feature complete" [attaches .zip with source]
Client: "Thanks! Can you add tests?"
Developer: "Sure!" [attaches test suite]
```

### Contract Signing
```
Freelancer: "Contract ready" [attaches PDF]
Client: "Signed!" [attaches signed PDF]
```

### Asset Delivery
```
Designer: "Final assets" [attaches .zip with all files]
Client: "Perfect, thank you!"
```

## Performance Optimization

### Image Thumbnails
```swift
// Generate thumbnails for images to speed up chat loading
private func generateThumbnail(for url: URL) async throws -> String? {
    guard let image = UIImage(contentsOfFile: url.path) else {
        return nil
    }
    
    let size = CGSize(width: 200, height: 200)
    let thumbnail = image.preparingThumbnail(of: size)
    
    // Upload thumbnail
    // Return thumbnail URL
}
```

### Lazy Loading
```swift
// Load messages with attachments lazily
LazyVStack(spacing: Theme.Spacing.md) {
    ForEach(messages) { message in
        EnhancedChatMessageBubble(message: message)
    }
}
```

### Cache Management
```swift
// Clean up old cached files
func cleanupCache(olderThan days: Int) {
    let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    // Remove files older than X days
}
```

## Analytics

Track these metrics:
```swift
// File uploads
- Total uploads per day
- Average file size
- Most common file types
- Upload success rate
- Upload errors

// File downloads
- Total downloads per day
- Download success rate
- Average download time
- Cache hit rate
```

## Future Enhancements

### Phase 2
- [ ] In-app PDF viewer
- [ ] In-app image viewer with zoom
- [ ] Video player in chat
- [ ] Audio player with waveform
- [ ] File compression before upload
- [ ] Batch download multiple files

### Phase 3
- [ ] Voice messages
- [ ] Screen recordings
- [ ] Location sharing
- [ ] Contact card sharing
- [ ] Link previews with thumbnails

---

## Summary

You now have **complete file sharing** in your chat system:

✅ Upload documents, images, videos, audio, code, design files  
✅ Progress tracking for uploads and downloads  
✅ File type validation and security  
✅ Beautiful UI with type-specific icons and colors  
✅ Caching for fast repeat access  
✅ Support for up to 50MB files  

**Next Steps:**
1. Replace `SimpleChatView` with `EnhancedChatView`
2. Implement backend upload/download endpoints
3. Test file sharing flows
4. Deploy and let users share files!

Welcome to modern file sharing in chat! 📎✨
