//
//  ThemeModifier.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

/// View modifier that applies the selected theme to the entire view hierarchy
struct ThemeModifier: ViewModifier {
    @StateObject private var themeManager = ThemeManager.shared
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.colorScheme)
    }
}

extension View {
    /// Apply theme management to this view
    func applyTheme() -> some View {
        modifier(ThemeModifier())
    }
}
