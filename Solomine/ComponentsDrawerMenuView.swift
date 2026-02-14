//
//  DrawerMenuView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct DrawerMenuView: View {
    @Binding var selectedTab: Int
    @Binding var isOpen: Bool
    
    let menuItems = [
        (index: 0, title: "EXPLORE", icon: "magnifyingglass", description: "Browse builders"),
        (index: 1, title: "GIGS", icon: "briefcase", description: "Service listings"),
        (index: 2, title: "MESSAGES", icon: "message", description: "Conversations"),
        (index: 3, title: "DASHBOARD", icon: "chart.bar", description: "Your activity"),
        (index: 4, title: "PROFILE", icon: "person", description: "Settings & account")
    ]
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Overlay - dismiss on tap
            if isOpen {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isOpen = false
                        }
                    }
            }
            
            // Drawer menu
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("AFFILIA")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(Theme.Colors.accent)
                            .kerning(2)
                        
                        Text("> navigation")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, Theme.Spacing.xl)
                    .padding(.bottom, Theme.Spacing.lg)
                    
                    Divider()
                        .background(Theme.Colors.border)
                    
                    // Menu items
                    ScrollView {
                        VStack(spacing: Theme.Spacing.xs) {
                            ForEach(menuItems, id: \.index) { item in
                                MenuItemButton(
                                    title: item.title,
                                    icon: item.icon,
                                    description: item.description,
                                    isSelected: selectedTab == item.index
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedTab = item.index
                                        isOpen = false
                                    }
                                }
                            }
                        }
                        .padding(.vertical, Theme.Spacing.md)
                    }
                    
                    Spacer()
                    
                    // Footer
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Divider()
                            .background(Theme.Colors.border)
                        
                        HStack {
                            Text("v1.0.0")
                                .font(Theme.Typography.tiny)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    isOpen = false
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.vertical, Theme.Spacing.md)
                    }
                }
                .frame(width: 280)
                .background(Theme.Colors.surface)
                .overlay(
                    Rectangle()
                        .fill(Theme.Colors.accent.opacity(0.1))
                        .frame(width: 1),
                    alignment: .trailing
                )
                
                Spacer()
            }
            .offset(x: isOpen ? 0 : -280)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isOpen)
    }
}

struct MenuItemButton: View {
    let title: String
    let icon: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                // Icon container
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .fill(isSelected ? Theme.Colors.accent.opacity(0.2) : Color.clear)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .regular, design: .monospaced))
                        .foregroundColor(isSelected ? Theme.Colors.accent : Theme.Colors.textSecondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Theme.Typography.body)
                        .foregroundColor(isSelected ? Theme.Colors.accent : Theme.Colors.textPrimary)
                    
                    Text(description)
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Rectangle()
                        .fill(Theme.Colors.accent)
                        .frame(width: 3, height: 40)
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.xs)
            .background(isSelected ? Theme.Colors.accent.opacity(0.05) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        Theme.Colors.background.ignoresSafeArea()
        
        DrawerMenuView(selectedTab: .constant(0), isOpen: .constant(true))
    }
}
