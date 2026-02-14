//
//  AuthenticationManager.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import Foundation
import AuthenticationServices
internal import Combine

// MARK: - Social Profile Models

struct XProfile: Codable, Sendable {
    let id: String
    let username: String
    let displayName: String
    let bio: String?
    let profileImageURL: String?
    let followers: Int
    let following: Int
    let verified: Bool
    let email: String?
}

/// Response from backend after X OAuth
struct XAuthResponse: Codable, Sendable {
    let token: String  // JWT or session token from your backend
    let profile: XProfile
}

struct GitHubProfile: Codable, Sendable {
    let id: String
    let username: String
    let name: String?
    let bio: String?
    let avatarURL: String?
    let publicRepos: Int
    let followers: Int
    let following: Int
}

/// Response from backend after GitHub OAuth
struct GitHubAuthResponse: Codable, Sendable {
    let token: String  // JWT or session token from your backend
    let profile: GitHubProfile
}

// MARK: - Authentication Manager

/// Handles authentication with X (Twitter) and GitHub
class AuthenticationManager: NSObject, ObservableObject {
    
    static let shared = AuthenticationManager()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var authenticationError: String?
    
    @Published var xProfile: XProfile?
    @Published var githubProfile: GitHubProfile?
    
    private var authSession: ASWebAuthenticationSession?
    
    private override init() {
        super.init()
    }
    
    // MARK: - X (Twitter) Authentication
    
    /// Sign in with X (Twitter)
    func signInWithX() {
        // In production, you would use X OAuth 2.0
        // This is a mock implementation showing the flow
        
        let clientId = "T3pTNzJCUURGSWR3QjM4RTVfenI6MTpjaQ" // Replace with your X OAuth client ID
        let redirectURI = "affilia://auth/x/callback"
        let authURL = URL(string: "https://twitter.com/i/oauth2/authorize?response_type=code&client_id=\(clientId)&redirect_uri=\(redirectURI)&scope=tweet.read%20users.read%20follows.read&state=state&code_challenge=challenge&code_challenge_method=plain")!
        
        authSession = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: "affilia"
        ) { [weak self] callbackURL, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    if (error as NSError).code != ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        self.authenticationError = "X authentication failed: \(error.localizedDescription)"
                    }
                }
                return
            }
            
            guard let callbackURL = callbackURL else {
                DispatchQueue.main.async {
                    self.authenticationError = "No callback URL received"
                }
                return
            }
            
            // Extract authorization code from callback
            self.handleXCallback(url: callbackURL)
        }
        
        authSession?.presentationContextProvider = self
        authSession?.prefersEphemeralWebBrowserSession = false
        authSession?.start()
    }
    
    private func handleXCallback(url: URL) {
        print("🔄 Callback URL received: \(url.absoluteString)")
        
        // Parse the callback URL to extract the authorization code
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("❌ Failed to parse URL components")
            DispatchQueue.main.async {
                self.authenticationError = "Invalid callback URL"
            }
            return
        }
        
        print("📋 Query items: \(components.queryItems ?? [])")
        
        // Check for error parameter (if X denied access)
        if let error = components.queryItems?.first(where: { $0.name == "error" })?.value {
            print("❌ X authorization error: \(error)")
            DispatchQueue.main.async {
                self.authenticationError = "X authorization failed: \(error)"
            }
            return
        }
        
        // Check for authorization code
        guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            print("❌ No authorization code found in callback")
            DispatchQueue.main.async {
                self.authenticationError = "Failed to extract authorization code from callback"
            }
            return
        }
        
        print("✅ Authorization code received: \(code)")
        
        // Exchange code for access token and fetch real X profile
        exchangeXCodeForProfile(code: code)
    }
    
    /// Exchange authorization code for access token and fetch real X profile
    private func exchangeXCodeForProfile(code: String) {
        // Backend URL - Update this with your deployed backend URL
        // For local development: "http://localhost:3000/api/auth/x/callback"
        // For production: "https://api.affilia.app/api/auth/x/callback"
        let backendURL = "http://localhost:3000/api/auth/x/callback"
        
        guard let url = URL(string: backendURL) else {
            print("❌ Invalid backend URL")
            simulateXAuthentication() // Fallback to mock for now
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "code": code,
            "redirect_uri": "affilia://auth/x/callback"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ Failed to encode request body: \(error)")
            simulateXAuthentication() // Fallback to mock
            return
        }
        
        print("🌐 Sending authorization code to backend...")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                // Fallback to mock data for development
                DispatchQueue.main.async {
                    self.simulateXAuthentication()
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                DispatchQueue.main.async {
                    self.simulateXAuthentication()
                }
                return
            }
            
            print("📡 Backend response status: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ Backend returned error status: \(httpResponse.statusCode)")
                if let data = data, let errorString = String(data: data, encoding: .utf8) {
                    print("❌ Error response: \(errorString)")
                }
                DispatchQueue.main.async {
                    self.simulateXAuthentication()
                }
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    self.simulateXAuthentication()
                }
                return
            }
            
            // Parse the response in a nonisolated context
            do {
                let decoder = JSONDecoder()
                let authResponse = try decoder.decode(XAuthResponse.self, from: data)
                print("✅ Successfully decoded X profile from backend")
                
                // Now move to main actor for UI updates
                DispatchQueue.main.async {
                    self.createUserFromXProfile(authResponse: authResponse)
                }
            } catch {
                print("❌ Failed to decode response: \(error)")
                // Fallback to mock for development
                DispatchQueue.main.async {
                    self.simulateXAuthentication()
                }
            }
        }.resume()
    }
    
    /// Create user from real X profile data
    @MainActor
    private func createUserFromXProfile(authResponse: XAuthResponse) {
        print("🔐 Creating user from X profile...")
        print("   - Username: @\(authResponse.profile.username)")
        print("   - Display Name: \(authResponse.profile.displayName)")
        print("   - Followers: \(authResponse.profile.followers)")
        
        // Store the X profile
        self.xProfile = authResponse.profile
        
        // Create user WITHOUT a role so they see RoleSelectionView
        let user = User(
            id: UUID(),
            email: authResponse.profile.email ?? "\(authResponse.profile.username)@x.com",
            role: nil,  // No role yet - user will select in RoleSelectionView
            freelancerProfile: FreelancerProfile(
                xUsername: authResponse.profile.username,
                displayName: authResponse.profile.displayName,
                bio: authResponse.profile.bio ?? "Affiliate on Affilia",
                skills: [],  // User will add skills later
                xFollowers: authResponse.profile.followers,
                xFollowing: authResponse.profile.following,
                xVerified: authResponse.profile.verified,
                xProfileImageURL: authResponse.profile.profileImageURL
            ),
            shortlistedFreelancers: []
        )
        
        self.currentUser = user
        self.isAuthenticated = true
        
        print("✅ Authentication complete! User should now select their role.")
        print("   - User ID: \(user.id)")
        print("   - X Username: @\(authResponse.profile.username)")
    }
    
    private func simulateXAuthentication() {
        print("⏳ Simulating X authentication (1 second delay)...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { 
                print("❌ Self was deallocated")
                return 
            }
            
            print("🔐 Creating mock X profile...")
            
            // Simulate fetched X profile
            self.xProfile = XProfile(
                id: "123456789",
                username: "robcodes",
                displayName: "Rob Behbahani",
                bio: "Growth operator and affiliate strategist. Building on Affilia.",
                profileImageURL: nil,
                followers: 5420,
                following: 892,
                verified: false,
                email: "rob@x.com"
            )
            
            print("👤 X Profile created: @\(self.xProfile!.username)")
            
            // Create user WITHOUT a role so they see RoleSelectionView
            // After X auth, user should choose if they're a builder or hiring
            let user = User(
                id: UUID(),
                email: self.xProfile!.email ?? "rob@x.com",
                role: nil,  // No role yet - user will select in RoleSelectionView
                freelancerProfile: FreelancerProfile(
                    xUsername: self.xProfile!.username,
                    displayName: self.xProfile!.displayName,
                    bio: self.xProfile!.bio ?? "Affiliate on Affilia",
                    skills: ["SwiftUI", "iOS", "API Design"],
                    xFollowers: self.xProfile!.followers,
                    xFollowing: self.xProfile!.following,
                    xVerified: self.xProfile!.verified,
                    xProfileImageURL: self.xProfile!.profileImageURL
                ),
                shortlistedFreelancers: []
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            
            print("✅ Authentication complete! User should now select their role.")
            print("   - User ID: \(user.id)")
            print("   - Role: \(user.role?.rawValue ?? "nil")")
            print("   - isAuthenticated: \(self.isAuthenticated)")
        }
    }
    
    // MARK: - GitHub Authentication
    
    /// Link GitHub account
    func linkGitHub() {
        // TODO: Replace with your actual GitHub OAuth Client ID from https://github.com/settings/developers
        // After creating your OAuth app, paste your Client ID here
        let clientId = "Ov23liVQKIWJjXw0BKIu"
        let redirectURI = "affilia://auth/github/callback"
        
        // Scopes: user:email (email access), read:user (profile access)
        let scopes = "user:email read:user"
        let encodedScopes = scopes.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let authURL = URL(string: "https://github.com/login/oauth/authorize?client_id=\(clientId)&redirect_uri=\(redirectURI)&scope=\(encodedScopes)&state=\(UUID().uuidString)")!
        
        authSession = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: "affilia"
        ) { [weak self] callbackURL, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    if (error as NSError).code != ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        self.authenticationError = "GitHub authentication failed: \(error.localizedDescription)"
                    }
                }
                return
            }
            
            guard let callbackURL = callbackURL else {
                DispatchQueue.main.async {
                    self.authenticationError = "No callback URL received"
                }
                return
            }
            
            self.handleGitHubCallback(url: callbackURL)
        }
        
        authSession?.presentationContextProvider = self
        authSession?.prefersEphemeralWebBrowserSession = false
        authSession?.start()
    }
    
    private func handleGitHubCallback(url: URL) {
        print("🔄 GitHub callback URL received: \(url.absoluteString)")
        
        // Parse the callback URL to extract the authorization code
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("❌ Failed to parse GitHub callback URL")
            DispatchQueue.main.async {
                self.authenticationError = "Invalid callback URL"
            }
            return
        }
        
        print("📋 GitHub query items: \(components.queryItems ?? [])")
        
        // Check for error parameter (if GitHub denied access)
        if let error = components.queryItems?.first(where: { $0.name == "error" })?.value {
            print("❌ GitHub authorization error: \(error)")
            DispatchQueue.main.async {
                self.authenticationError = "GitHub authorization failed: \(error)"
            }
            return
        }
        
        // Check for authorization code
        guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            print("❌ No authorization code found in GitHub callback")
            DispatchQueue.main.async {
                self.authenticationError = "Failed to extract authorization code from callback"
            }
            return
        }
        
        print("✅ GitHub authorization code received: \(code)")
        
        // Exchange code for access token and fetch real GitHub profile
        exchangeGitHubCodeForProfile(code: code)
    }
    
    /// Exchange GitHub authorization code for access token and fetch profile
    private func exchangeGitHubCodeForProfile(code: String) {
        // Backend URL - Update this with your deployed backend URL
        // For local development: "http://localhost:3000/api/auth/github/callback"
        // For production: "https://api.affilia.app/api/auth/github/callback"
        let backendURL = "http://localhost:3000/api/auth/github/callback"
        
        guard let url = URL(string: backendURL) else {
            print("❌ Invalid backend URL")
            simulateGitHubLink() // Fallback to mock for now
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "code": code,
            "redirect_uri": "affilia://auth/github/callback"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ Failed to encode GitHub request body: \(error)")
            simulateGitHubLink() // Fallback to mock
            return
        }
        
        print("🌐 Sending GitHub authorization code to backend...")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ GitHub network error: \(error.localizedDescription)")
                // Fallback to mock data for development
                DispatchQueue.main.async {
                    self.simulateGitHubLink()
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid GitHub response")
                DispatchQueue.main.async {
                    self.simulateGitHubLink()
                }
                return
            }
            
            print("📡 GitHub backend response status: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ GitHub backend returned error status: \(httpResponse.statusCode)")
                if let data = data, let errorString = String(data: data, encoding: .utf8) {
                    print("❌ GitHub error response: \(errorString)")
                }
                DispatchQueue.main.async {
                    self.simulateGitHubLink()
                }
                return
            }
            
            guard let data = data else {
                print("❌ No data received from GitHub")
                DispatchQueue.main.async {
                    self.simulateGitHubLink()
                }
                return
            }
            
            // Parse the response
            do {
                let decoder = JSONDecoder()
                let githubResponse = try decoder.decode(GitHubAuthResponse.self, from: data)
                print("✅ Successfully decoded GitHub profile from backend")
                
                // Now move to main actor for UI updates
                DispatchQueue.main.async {
                    self.linkGitHubProfile(githubResponse: githubResponse)
                }
            } catch {
                print("❌ Failed to decode GitHub response: \(error)")
                // Fallback to mock for development
                DispatchQueue.main.async {
                    self.simulateGitHubLink()
                }
            }
        }.resume()
    }
    
    /// Link GitHub profile to current user
    @MainActor
    private func linkGitHubProfile(githubResponse: GitHubAuthResponse) {
        print("🔗 Linking GitHub profile to user...")
        print("   - Username: @\(githubResponse.profile.username)")
        print("   - Name: \(githubResponse.profile.name ?? "N/A")")
        print("   - Public Repos: \(githubResponse.profile.publicRepos)")
        
        // Store the GitHub profile
        self.githubProfile = githubResponse.profile
        
        // Update current user's freelancer profile with GitHub data
        if currentUser?.freelancerProfile != nil {
            // You can enhance the profile with GitHub stats
            print("✅ GitHub linked successfully!")
            print("   - Public Repos: \(githubResponse.profile.publicRepos)")
            print("   - Followers: \(githubResponse.profile.followers)")
        }
        
        print("✅ GitHub linking complete!")
    }
    
    private func simulateGitHubLink() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.githubProfile = GitHubProfile(
                id: "987654321",
                username: "robcodes",
                name: "Rob Behbahani",
                bio: "Building things that matter",
                avatarURL: nil,
                publicRepos: 42,
                followers: 234,
                following: 89
            )
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        xProfile = nil
        githubProfile = nil
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
extension AuthenticationManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            // Fallback to the first connected window scene
            fatalError("No active window scene available")
        }
        return ASPresentationAnchor(windowScene: windowScene)
    }
}

