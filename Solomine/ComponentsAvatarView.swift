//
//  AvatarView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

/// Terminal-style avatar using initials
struct AvatarView: View {
    let displayName: String
    let size: CGFloat
    
    var initials: String {
        let components = displayName.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        return "??"
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                .fill(Theme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                )
            
            Text(initials)
                .font(.system(size: size * 0.4, weight: .bold, design: .monospaced))
                .foregroundColor(Theme.Colors.accent)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 20) {
        AvatarView(displayName: "Rob Behbahani", size: 60)
        AvatarView(displayName: "Alex Chen", size: 40)
        AvatarView(displayName: "Maya Rodriguez", size: 80)
    }
    .padding()
    .background(Theme.Colors.background)
}
