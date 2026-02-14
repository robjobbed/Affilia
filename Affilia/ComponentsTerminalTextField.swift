//
//  TerminalTextField.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct TerminalTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Text(">")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Theme.Colors.textSecondary))
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textPrimary)
                .keyboardType(keyboardType)
        }
        .padding(Theme.Spacing.sm)
        .background(Theme.Colors.surface)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
        )
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

#Preview {
    VStack(spacing: 20) {
        TerminalTextField(placeholder: "Enter text", text: .constant(""))
        TerminalTextField(placeholder: "Enter number", text: .constant("42"), keyboardType: .numberPad)
    }
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}
