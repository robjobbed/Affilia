//
//  ModernToolbar.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct ModernToolbar: View {
    @Binding var isDrawerOpen: Bool
    let title: String
    let showBackButton: Bool
    let onBack: (() -> Void)?
    
    init(isDrawerOpen: Binding<Bool>, title: String, showBackButton: Bool = false, onBack: (() -> Void)? = nil) {
        self._isDrawerOpen = isDrawerOpen
        self.title = title
        self.showBackButton = showBackButton
        self.onBack = onBack
    }
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Menu button or back button
            if showBackButton {
                Button(action: { onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundColor(Theme.Colors.accent)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Theme.Colors.backgroundElevated)
                                .overlay(
                                    Circle()
                                        .stroke(Theme.Colors.border, lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            } else {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isDrawerOpen.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.backgroundElevated)
                            .overlay(
                                Circle()
                                    .stroke(isDrawerOpen ? Theme.Colors.accent : Theme.Colors.border, lineWidth: 1)
                            )
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: isDrawerOpen ? "xmark" : "line.3.horizontal")
                            .font(.system(size: 18, weight: .semibold, design: .monospaced))
                            .foregroundColor(isDrawerOpen ? Theme.Colors.accent : Theme.Colors.textPrimary)
                            .rotationEffect(.degrees(isDrawerOpen ? 90 : 0))
                    }
                }
                .buttonStyle(ScaleButtonStyle())
            }
            
            // Title with animation
            Text(title.uppercased())
                .font(Theme.Typography.title)
                .foregroundColor(Theme.Colors.accent)
                .kerning(2)
                .animation(.easeInOut(duration: 0.2), value: title)
            
            Spacer()
            
            // Status indicator (optional - shows online/offline)
            HStack(spacing: Theme.Spacing.xs) {
                Circle()
                    .fill(Theme.Colors.accent)
                    .frame(width: 6, height: 6)
                    .overlay(
                        Circle()
                            .fill(Theme.Colors.accent)
                            .frame(width: 6, height: 6)
                            .scaleEffect(1.5)
                            .opacity(0.3)
                    )
                
                Text("ONLINE")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, 4)
            .background(Theme.Colors.backgroundElevated)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.Colors.border, lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .background(
            Theme.Colors.surface
                .shadow(color: Theme.Colors.accent.opacity(0.1), radius: 10, y: 5)
        )
    }
}

// Button style with scale animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    VStack {
        ModernToolbar(isDrawerOpen: .constant(false), title: "Explore")
        ModernToolbar(isDrawerOpen: .constant(true), title: "Dashboard")
        ModernToolbar(isDrawerOpen: .constant(false), title: "Profile", showBackButton: true, onBack: {})
    }
    .background(Theme.Colors.background)
}
