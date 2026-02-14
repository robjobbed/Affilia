//
//  TerminalHeader.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct TerminalHeader: View {
    let title: String
    
    var body: some View {
        Text(title.uppercased())
            .font(Theme.Typography.title)
            .foregroundColor(Theme.Colors.textPrimary)
            .kerning(Theme.Typography.headerLetterSpacing)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.md)
            .padding(.bottom, Theme.Spacing.sm)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String?
    
    init(_ title: String, icon: String? = nil) {
        self.title = title
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(Theme.Colors.accent)
            }
            
            Text("> " + title.uppercased())
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.accent)
            
            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
    }
}
