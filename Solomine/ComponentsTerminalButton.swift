//
//  TerminalButton.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct TerminalButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    init(_ title: String, isActive: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isActive = isActive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.body)
                .foregroundColor(isActive ? Theme.Colors.background : Theme.Colors.accent)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .frame(maxWidth: .infinity)
                .background(isActive ? Theme.Colors.accent : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                )
                .cornerRadius(Theme.CornerRadius.medium)
        }
    }
}

struct TerminalButtonSmall: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.accent)
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, Theme.Spacing.xs)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                )
                .cornerRadius(Theme.CornerRadius.small)
        }
    }
}

struct TerminalButtonIcon: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .regular, design: .monospaced))
                .foregroundColor(Theme.Colors.accent)
                .padding(Theme.Spacing.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                )
                .cornerRadius(Theme.CornerRadius.small)
        }
    }
}
