//
//  Config.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/4/26.
//

import Foundation

/// Application configuration for different environments
struct Config {
    
    // MARK: - Environment
    
    /// Set to `true` for production builds, `false` for development
    /// This should be controlled via build schemes in production
    static let isProduction = false  // TODO: Set to true before App Store submission
    
    // MARK: - API Configuration
    
    /// Base URL for backend API
    static let apiBaseURL: String = {
        if isProduction {
            return "https://api.solomine.io"  // TODO: Replace with your production API
        } else {
            return "http://localhost:3000"
        }
    }()
    
    /// API version
    static let apiVersion = "v1"
    
    /// Full API URL
    static var fullAPIURL: String {
        return "\(apiBaseURL)/\(apiVersion)"
    }
    
    // MARK: - OAuth Configuration
    
    /// X (Twitter) OAuth Client ID
    static let xClientID = "T3pTNzJCUURGSWR3QjM4RTVfenI6MTpjaQ"  // TODO: Replace with your X OAuth client ID
    
    /// OAuth Redirect URI
    static let oauthRedirectURI = "solomine://auth/x/callback"
    
    /// GitHub OAuth Client ID
    static let githubClientID = "YOUR_GITHUB_CLIENT_ID"  // TODO: Replace with your GitHub OAuth client ID
    
    // MARK: - Feature Flags
    
    /// Enable real backend communication (vs mock data)
    static let useRealBackend = false  // Set to true when backend is ready
    
    /// Enable payment features
    static let enablePayments = false  // Set to true when payments are ready
    
    /// Enable push notifications
    static let enablePushNotifications = false  // Set to true when notifications are ready
    
    /// Enable GitHub integration
    static let enableGitHubIntegration = false  // Set to true when GitHub is ready
    
    /// Enable file attachments in chat
    static let enableFileAttachments = false  // Set to true in v1.1
    
    /// Enable analytics
    static let enableAnalytics = isProduction
    
    /// Enable crash reporting
    static let enableCrashReporting = isProduction
    
    // MARK: - App Information
    
    /// App version (should match Info.plist)
    static let appVersion = "1.0.0"
    
    /// App build number (should match Info.plist)
    static let buildNumber = "1"
    
    /// Support email
    static let supportEmail = "rob@solomine.io"
    
    /// Privacy policy URL
    static let privacyPolicyURL = "https://solomine.io/privacy"  // TODO: Host privacy policy
    
    /// Terms of service URL
    static let termsOfServiceURL = "https://solomine.io/terms"  // TODO: Host terms of service
    
    // MARK: - Debug Settings
    
    /// Show debug logs
    static let showDebugLogs = !isProduction
    
    /// Log network requests
    static let logNetworkRequests = !isProduction
    
    // MARK: - Limits
    
    /// Maximum message length
    static let maxMessageLength = 2000
    
    /// Maximum file size for attachments (in bytes) - 10 MB
    static let maxFileSize = 10 * 1024 * 1024
    
    /// Minimum payment amount (in dollars)
    static let minPaymentAmount = 1.0
    
    /// Maximum payment amount (in dollars)
    static let maxPaymentAmount = 100_000.0
    
    // MARK: - Helper Methods
    
    /// Print debug log if debug logs are enabled
    static func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        if showDebugLogs {
            let fileName = (file as NSString).lastPathComponent
            print("[\(fileName):\(line)] \(function) - \(message)")
        }
        #endif
    }
    
    /// Print network log if network logging is enabled
    static func logNetwork(_ message: String) {
        #if DEBUG
        if logNetworkRequests {
            print("🌐 [NETWORK] \(message)")
        }
        #endif
    }
}

// MARK: - Build Configuration Helper

extension Config {
    
    /// Check if this is a debug build
    static var isDebugBuild: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    /// Check if this is a release build
    static var isReleaseBuild: Bool {
        return !isDebugBuild
    }
    
    /// Check if running in simulator
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    /// Full app version string
    static var fullVersionString: String {
        return "\(appVersion) (\(buildNumber))"
    }
}

// MARK: - URL Builder

extension Config {
    
    /// Build API endpoint URL
    static func apiURL(for endpoint: String) -> URL? {
        let urlString = "\(fullAPIURL)\(endpoint)"
        return URL(string: urlString)
    }
}
