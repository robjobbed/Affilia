//
//  AnimatedCard.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

/// Animated card wrapper with hover and tap effects
struct AnimatedCard<Content: View>: View {
    let content: Content
    @State private var isPressed = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .shadow(
                color: isPressed ? Theme.Colors.accent.opacity(0.2) : Color.clear,
                radius: isPressed ? 8 : 0,
                y: isPressed ? 4 : 0
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        isPressed = true
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
    }
}

/// Card with slide-in animation
struct SlideInCard<Content: View>: View {
    let content: Content
    let delay: Double
    @State private var appeared = false
    
    init(delay: Double = 0, @ViewBuilder content: () -> Content) {
        self.delay = delay
        self.content = content()
    }
    
    var body: some View {
        content
            .offset(x: appeared ? 0 : 50)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    appeared = true
                }
            }
    }
}

/// Loading shimmer effect
struct ShimmerEffect: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        LinearGradient(
            colors: [
                Theme.Colors.surface,
                Theme.Colors.accent.opacity(0.1),
                Theme.Colors.surface
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 100)
        .mask(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white, .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .offset(x: phase)
        )
        .onAppear {
            withAnimation(
                Animation
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
            ) {
                phase = 300
            }
        }
    }
}

/// Pulsing badge for notifications
struct PulsingBadge: View {
    let count: Int
    @State private var isPulsing = false
    
    var body: some View {
        if count > 0 {
            Text("\(count)")
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.background)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(Theme.Colors.accent)
                        .overlay(
                            Capsule()
                                .fill(Theme.Colors.accent)
                                .scaleEffect(isPulsing ? 1.3 : 1.0)
                                .opacity(isPulsing ? 0 : 0.5)
                        )
                )
                .onAppear {
                    withAnimation(
                        Animation
                            .easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: false)
                    ) {
                        isPulsing = true
                    }
                }
        }
    }
}

/// Success checkmark animation
struct SuccessCheckmark: View {
    @State private var trimEnd: CGFloat = 0
    @State private var scale: CGFloat = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.Colors.accent, lineWidth: 2)
                .frame(width: 60, height: 60)
                .scaleEffect(scale)
            
            Path { path in
                path.move(to: CGPoint(x: 20, y: 30))
                path.addLine(to: CGPoint(x: 28, y: 38))
                path.addLine(to: CGPoint(x: 42, y: 22))
            }
            .trim(from: 0, to: trimEnd)
            .stroke(Theme.Colors.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .frame(width: 60, height: 60)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                trimEnd = 1.0
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AnimatedCard {
            Text("Tap me")
                .padding()
                .frame(maxWidth: .infinity)
                .terminalCard()
        }
        
        SlideInCard(delay: 0.2) {
            Text("I slide in")
                .padding()
                .terminalCard()
        }
        
        ShimmerEffect()
            .terminalCard()
        
        HStack {
            PulsingBadge(count: 3)
            PulsingBadge(count: 12)
        }
        
        SuccessCheckmark()
    }
    .padding()
    .background(Theme.Colors.background)
}
