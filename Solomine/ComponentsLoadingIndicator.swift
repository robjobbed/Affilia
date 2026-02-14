//
//  LoadingIndicator.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI
internal import Combine

struct LoadingIndicator: View {
    @State private var dotCount = 0
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 0) {
            Text("> loading")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.accent)
            
            Text(String(repeating: ".", count: dotCount))
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.accent)
                .frame(width: 30, alignment: .leading)
        }
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 4
        }
    }
}

struct BlinkingCursor: View {
    @State private var isVisible = true
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text("_")
            .font(Theme.Typography.body)
            .foregroundColor(Theme.Colors.accent)
            .opacity(isVisible ? 1 : 0)
            .onReceive(timer) { _ in
                isVisible.toggle()
            }
    }
}

struct TerminalProgressBar: View {
    let progress: Double // 0.0 to 1.0
    let width: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            let filledCount = Int(progress * 20)
            let emptyCount = 20 - filledCount
            
            Text(String(repeating: "█", count: filledCount))
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.accent)
            
            Text(String(repeating: "░", count: emptyCount))
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.border)
        }
        .frame(width: width, alignment: .leading)
    }
}
