//
//  MainTabView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var isDrawerOpen = false
    
    var currentTitle: String {
        switch selectedTab {
        case 0: return "Explore"
        case 1: return "Campaigns"
        case 2: return "Messages"
        case 3: return "Dashboard"
        case 4: return "Profile"
        default: return "Affilia"
        }
    }
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Modern toolbar at top
                ModernToolbar(isDrawerOpen: $isDrawerOpen, title: currentTitle)
                
                // Main content area with transition animations
                Group {
                    switch selectedTab {
                    case 0:
                        ExploreView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    case 1:
                        GigsView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    case 2:
                        MessagesView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    case 3:
                        DashboardView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    case 4:
                        ProfileView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    default:
                        ExploreView()
                    }
                }
                .id(selectedTab) // Force view recreation for animation
            }
            
            // Drawer menu overlay
            DrawerMenuView(selectedTab: $selectedTab, isOpen: $isDrawerOpen)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}
