//
//  SolomineApp.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

@main
struct AffiliaApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    if authManager.currentUser?.role != nil {
                        // User is authenticated and has selected role
                        ModernMainView()
                            .environmentObject(authManager)
                    } else {
                        // User is authenticated but needs to select role
                        RoleSelectionView()
                    }
                } else {
                    // User is not authenticated
                    LoginView()
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
