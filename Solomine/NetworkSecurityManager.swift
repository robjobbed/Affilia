//
//  NetworkSecurityManager.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import Foundation
import CryptoKit

/// Handles secure network communications with the backend
class NetworkSecurityManager {
    
    static let shared = NetworkSecurityManager()
    
    // Production backend URL
    private let baseURL = "https://api.solomine.dev"
    
    // API version
    private let apiVersion = "v1"
    
    // Security headers
    private var defaultHeaders: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-API-Version": apiVersion,
            "X-Platform": "iOS",
            "X-App-Version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        ]
    }
    
    private init() {}
    
    // MARK: - Secure API Requests
    
    func makeSecureRequest<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        
        // 1. Build URL
        guard let url = URL(string: "\(baseURL)/\(apiVersion)/\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        // 2. Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30
        
        // 3. Add security headers
        for (key, value) in defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // 4. Add authentication token if required
        if requiresAuth {
            if let token = try? getAuthToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw NetworkError.unauthorized
            }
        }
        
        // 5. Add request body
        if let body = body {
            request.httpBody = body
            
            // Add integrity hash for mutation requests
            if method != .get {
                let hash = hashData(body)
                request.setValue(hash, forHTTPHeaderField: "X-Content-Hash")
            }
        }
        
        // 6. Add timestamp to prevent replay attacks
        let timestamp = String(Int(Date().timeIntervalSince1970))
        request.setValue(timestamp, forHTTPHeaderField: "X-Request-Time")
        
        // 7. Generate request signature (production)
        // let signature = generateRequestSignature(url: url, timestamp: timestamp, body: body)
        // request.setValue(signature, forHTTPHeaderField: "X-Request-Signature")
        
        // 8. Make request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 9. Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // 10. Check status code
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // 11. Verify response integrity (production)
        // if let responseHash = httpResponse.value(forHTTPHeaderField: "X-Content-Hash") {
        //     let computedHash = hashData(data)
        //     guard responseHash == computedHash else {
        //         throw NetworkError.integrityCheckFailed
        //     }
        // }
        
        // 12. Decode response
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    // MARK: - Token Management
    
    private func getAuthToken() throws -> String {
        // In production: Retrieve from secure Keychain storage
        // For now, return placeholder
        return "mock_auth_token_\(UUID().uuidString)"
    }
    
    func saveAuthToken(_ token: String) throws {
        // Save to Keychain
        let data = token.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "auth_token",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing
        SecItemDelete(query as CFDictionary)
        
        // Add new
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NetworkError.keychainError
        }
    }
    
    func deleteAuthToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "auth_token"
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Security Utilities
    
    private func hashData(_ data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func generateRequestSignature(url: URL, timestamp: String, body: Data?) -> String {
        // In production: Implement HMAC-SHA256 signature
        // Example: HMAC(secret_key, method + url + timestamp + body_hash)
        
        var signatureData = url.absoluteString + timestamp
        if let body = body {
            signatureData += hashData(body)
        }
        
        // This is a placeholder - in production, use actual HMAC
        return hashData(Data(signatureData.utf8))
    }
    
    // MARK: - Certificate Pinning (Production)
    
    func setupCertificatePinning() {
        // In production: Implement SSL certificate pinning
        // This prevents man-in-the-middle attacks
        
        /*
        Example implementation:
        
        class NetworkDelegate: NSObject, URLSessionDelegate {
            func urlSession(
                _ session: URLSession,
                didReceive challenge: URLAuthenticationChallenge,
                completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
            ) {
                guard let serverTrust = challenge.protectionSpace.serverTrust else {
                    completionHandler(.cancelAuthenticationChallenge, nil)
                    return
                }
                
                let pinnedCertificates = [/* Your pinned certificates */]
                
                if validateServerTrust(serverTrust, pinnedCertificates: pinnedCertificates) {
                    completionHandler(.useCredential, URLCredential(trust: serverTrust))
                } else {
                    completionHandler(.cancelAuthenticationChallenge, nil)
                }
            }
        }
        */
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - Network Errors

enum NetworkError: LocalizedError {
    case invalidURL
    case unauthorized
    case invalidResponse
    case httpError(statusCode: Int)
    case integrityCheckFailed
    case decodingError(Error)
    case keychainError
    case networkUnavailable
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API endpoint URL"
        case .unauthorized:
            return "Authentication required. Please log in again."
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode):
            return "Server error: \(statusCode)"
        case .integrityCheckFailed:
            return "Response integrity check failed"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .keychainError:
            return "Failed to access secure storage"
        case .networkUnavailable:
            return "No internet connection"
        }
    }
}

// MARK: - API Response Models

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: APIError?
    let timestamp: Date
    let requestId: String
}

struct APIError: Decodable {
    let code: String
    let message: String
    let details: [String: String]?
}

// MARK: - Example Usage

extension NetworkSecurityManager {
    
    // Example: Fetch messages
    func fetchMessages(conversationId: UUID) async throws -> [Message] {
        let response: APIResponse<[Message]> = try await makeSecureRequest(
            endpoint: "messages/\(conversationId.uuidString)",
            method: .get,
            requiresAuth: true
        )
        
        guard response.success, let messages = response.data else {
            throw NetworkError.invalidResponse
        }
        
        return messages
    }
    
    // Example: Send message
    func sendMessage(_ message: Message) async throws -> Message {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(message)
        
        let response: APIResponse<Message> = try await makeSecureRequest(
            endpoint: "messages",
            method: .post,
            body: body,
            requiresAuth: true
        )
        
        guard response.success, let sentMessage = response.data else {
            throw NetworkError.invalidResponse
        }
        
        return sentMessage
    }
    
    // Example: Process payment
    func processPayment(paymentRequest: PaymentRequest, paymentToken: String) async throws -> PaymentConfirmation {
        struct PaymentPayload: Encodable {
            let paymentRequestId: UUID
            let paymentToken: String
            let timestamp: Date
        }
        
        let payload = PaymentPayload(
            paymentRequestId: paymentRequest.id,
            paymentToken: paymentToken,
            timestamp: Date()
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(payload)
        
        let response: APIResponse<PaymentConfirmation> = try await makeSecureRequest(
            endpoint: "payments/process",
            method: .post,
            body: body,
            requiresAuth: true
        )
        
        guard response.success, let confirmation = response.data else {
            throw NetworkError.invalidResponse
        }
        
        return confirmation
    }
}

// MARK: - Payment Confirmation Model

struct PaymentConfirmation: Codable {
    let id: UUID
    let paymentRequestId: UUID
    let amount: Double
    let currency: String
    let status: String
    let transactionId: String
    let processedAt: Date
}
