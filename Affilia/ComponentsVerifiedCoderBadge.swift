//
//  VerifiedCoderBadge.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/4/26.
//

import SwiftUI

/// Displays a "Verified Coder" badge with optional tooltip
struct VerifiedCoderBadge: View {
    
    var size: BadgeSize = .medium
    var showLabel: Bool = true
    
    enum BadgeSize {
        case small, medium, large
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small: return Theme.Typography.tiny
            case .medium: return Theme.Typography.caption
            case .large: return Theme.Typography.small
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return Theme.Spacing.xs
            case .medium: return Theme.Spacing.sm
            case .large: return Theme.Spacing.md
            }
        }
    }
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: size.iconSize))
                .foregroundColor(Theme.Colors.accent)
            
            if showLabel {
                Text("VERIFIED CODER")
                    .font(size.fontSize)
                    .foregroundColor(Theme.Colors.accent)
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, size.padding)
        .padding(.vertical, size.padding / 2)
        .background(Theme.Colors.accent.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
        )
        .cornerRadius(Theme.CornerRadius.small)
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.md) {
        VerifiedCoderBadge(size: .small, showLabel: true)
        VerifiedCoderBadge(size: .medium, showLabel: true)
        VerifiedCoderBadge(size: .large, showLabel: true)
        VerifiedCoderBadge(size: .medium, showLabel: false)
    }
    .padding()
    .background(Theme.Colors.background)
}
