//
//  SkillTag.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct SkillTag: View {
    let skill: String
    
    var body: some View {
        Text(skill.uppercased())
            .font(Theme.Typography.tiny)
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

struct CategoryTag: View {
    let category: String
    let color: Color
    
    init(category: String, color: Color = Theme.Colors.accentSecondary) {
        self.category = category
        self.color = color
    }
    
    var body: some View {
        Text(category.uppercased())
            .font(Theme.Typography.tiny)
            .foregroundColor(color)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .stroke(color, lineWidth: Theme.BorderWidth.thin)
            )
            .cornerRadius(Theme.CornerRadius.small)
    }
}

struct StatusTag: View {
    let status: AvailabilityStatus
    
    var statusColor: Color {
        switch status {
        case .openToWork:
            return Theme.Colors.accent
        case .booked:
            return Theme.Colors.accentSecondary
        case .selective:
            return Theme.Colors.textSecondary
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(Theme.Typography.tiny)
            .foregroundColor(statusColor)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .stroke(statusColor, lineWidth: Theme.BorderWidth.thin)
            )
            .cornerRadius(Theme.CornerRadius.small)
    }
}
