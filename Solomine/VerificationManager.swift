//
//  VerificationManager.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/4/26.
//

import Foundation
internal import Combine

/// Manages builder verification requests and approval workflow
class VerificationManager: ObservableObject {
    
    static let shared = VerificationManager()
    
    @Published var pendingRequests: [VerificationRequest] = []
    @Published var allRequests: [VerificationRequest] = []
    
    private init() {
        loadMockRequests()
    }
    
    // MARK: - Request Verification
    
    /// Submit a verification request for a builder
    func requestVerification(for userId: UUID) {
        let request = VerificationRequest(userId: userId)
        allRequests.append(request)
        pendingRequests.append(request)
        
        print("✅ Verification request submitted for user: \(userId)")
        
        // In production, this would POST to your backend API
        // POST /api/verification/request
    }
    
    // MARK: - Review Verification
    
    /// Approve a verification request
    func approveVerification(
        requestId: UUID,
        reviewedBy: String,
        notes: String,
        portfolioReviewed: Bool,
        githubReviewed: Bool,
        skillsVerified: Bool,
        professionalismScore: Int
    ) {
        guard let index = allRequests.firstIndex(where: { $0.id == requestId }) else {
            print("❌ Verification request not found: \(requestId)")
            return
        }
        
        allRequests[index].status = .approved
        allRequests[index].reviewedDate = Date()
        allRequests[index].reviewedBy = reviewedBy
        allRequests[index].reviewNotes = notes
        allRequests[index].portfolioReviewed = portfolioReviewed
        allRequests[index].githubReviewed = githubReviewed
        allRequests[index].skillsVerified = skillsVerified
        allRequests[index].professionalismScore = professionalismScore
        
        // Remove from pending
        pendingRequests.removeAll { $0.id == requestId }
        
        // Update the user's profile (in production, this would be handled by backend)
        updateUserVerificationStatus(userId: allRequests[index].userId, isVerified: true, notes: notes)
        
        print("✅ Verification approved for request: \(requestId)")
        
        // In production, this would PUT to your backend API
        // PUT /api/verification/\(requestId)/approve
    }
    
    /// Reject a verification request
    func rejectVerification(
        requestId: UUID,
        reviewedBy: String,
        reason: String
    ) {
        guard let index = allRequests.firstIndex(where: { $0.id == requestId }) else {
            print("❌ Verification request not found: \(requestId)")
            return
        }
        
        allRequests[index].status = .rejected
        allRequests[index].reviewedDate = Date()
        allRequests[index].reviewedBy = reviewedBy
        allRequests[index].reviewNotes = reason
        
        // Remove from pending
        pendingRequests.removeAll { $0.id == requestId }
        
        print("❌ Verification rejected for request: \(requestId)")
        
        // In production, this would PUT to your backend API
        // PUT /api/verification/\(requestId)/reject
    }
    
    // MARK: - User Profile Updates
    
    /// Update user's verification status in their profile
    private func updateUserVerificationStatus(userId: UUID, isVerified: Bool, notes: String) {
        // This is a placeholder - in production, you'd update via your backend
        // and the backend would update the database
        
        // For now, we'll update AuthenticationManager's current user if it matches
        DispatchQueue.main.async {
            if AuthenticationManager.shared.currentUser?.id == userId {
                AuthenticationManager.shared.currentUser?.freelancerProfile?.isVerifiedCoder = isVerified
                AuthenticationManager.shared.currentUser?.freelancerProfile?.verificationDate = Date()
                AuthenticationManager.shared.currentUser?.freelancerProfile?.verificationNotes = notes
                print("✅ User profile updated with verification status")
            }
        }
        
        // In production: PATCH /api/users/\(userId)/verification
    }
    
    // MARK: - Query Methods
    
    /// Get verification request for a specific user
    func getVerificationRequest(for userId: UUID) -> VerificationRequest? {
        return allRequests.first { $0.userId == userId }
    }
    
    /// Check if user has pending verification request
    func hasPendingRequest(for userId: UUID) -> Bool {
        return pendingRequests.contains { $0.userId == userId }
    }
    
    /// Get all approved verifications
    func getApprovedVerifications() -> [VerificationRequest] {
        return allRequests.filter { $0.status == .approved }
    }
    
    /// Get all rejected verifications
    func getRejectedVerifications() -> [VerificationRequest] {
        return allRequests.filter { $0.status == .rejected }
    }
    
    // MARK: - Mock Data
    
    private func loadMockRequests() {
        // Create some mock pending requests for testing
        let mockRequest1 = VerificationRequest(
            userId: UUID(),
            status: .pending,
            submittedDate: Date().addingTimeInterval(-86400 * 2) // 2 days ago
        )
        
        let mockRequest2 = VerificationRequest(
            userId: UUID(),
            status: .pending,
            submittedDate: Date().addingTimeInterval(-86400 * 5) // 5 days ago
        )
        
        let mockRequest3 = VerificationRequest(
            userId: UUID(),
            status: .approved,
            submittedDate: Date().addingTimeInterval(-86400 * 10),
            reviewedDate: Date().addingTimeInterval(-86400 * 8),
            reviewedBy: "admin@solomine.app",
            reviewNotes: "Excellent portfolio and strong GitHub presence",
            portfolioReviewed: true,
            githubReviewed: true,
            skillsVerified: true,
            professionalismScore: 5
        )
        
        allRequests = [mockRequest1, mockRequest2, mockRequest3]
        pendingRequests = [mockRequest1, mockRequest2]
    }
}
