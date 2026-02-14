//
//  AnimatedCard.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

/// Card with hover animations and smooth transitions
struct AnimatedCard<Content: View>: View {
    let content: Content
    @State private var isPressed = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

/// Animated terminal card with glow effect
struct AnimatedTerminalCard<Content: View>: View {
    let content: Content
    @State private var isHovered = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(Theme.Colors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(isHovered ? Theme.Colors.accent : Theme.Colors.border, lineWidth: isHovered ? 2 : Theme.BorderWidth.thin)
                    .animation(.easeInOut(duration: 0.2), value: isHovered)
            )
            .cornerRadius(Theme.CornerRadius.medium)
            .shadow(color: isHovered ? Theme.Colors.accent.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onTapGesture {}
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isHovered = true }
                    .onEnded { _ in isHovered = false }
            )
    }
}

/// Slide-in animation for list items
struct SlideInView<Content: View>: View {
    let content: Content
    let delay: Double
    @State private var isVisible = false
    
    init(delay: Double = 0, @ViewBuilder content: () -> Content) {
        self.delay = delay
        self.content = content()
    }
    
    var body: some View {
        content
            .offset(x: isVisible ? 0 : -30)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

/// Fade-in animation
struct FadeInView<Content: View>: View {
    let content: Content
    let delay: Double
    @State private var isVisible = false
    
    init(delay: Double = 0, @ViewBuilder content: () -> Content) {
        self.delay = delay
        self.content = content()
    }
    
    var body: some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.4).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

/// Scale-in animation for interactive elements
struct ScaleInView<Content: View>: View {
    let content: Content
    let delay: Double
    @State private var isVisible = false
    
    init(delay: Double = 0, @ViewBuilder content: () -> Content) {
        self.delay = delay
        self.content = content()
    }
    
    var body: some View {
        content
            .scaleEffect(isVisible ? 1 : 0.8)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

/// Scanline effect overlay
struct ScanlineOverlay: View {
    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Theme.Colors.accent.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 100)
                .offset(y: offset)
                .onAppear {
                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                        offset = geometry.size.height
                    }
                }
        }
        .allowsHitTesting(false)
    }
}

/// Glitch text effect
struct GlitchText: View {
    let text: String
    @State private var offset: CGFloat = 0
    @State private var showGlitch = false
    
    var body: some View {
        ZStack {
            Text(text)
                .foregroundColor(Theme.Colors.accent)
            
            if showGlitch {
                Text(text)
                    .foregroundColor(Theme.Colors.accentSecondary.opacity(0.7))
                    .offset(x: offset, y: offset)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.05)) {
                    showGlitch = Bool.random()
                    offset = CGFloat.random(in: -2...2)
                }
            }
        }
    }
}

/// Pulse animation for notifications
struct PulseView<Content: View>: View {
    let content: Content
    @State private var scale: CGFloat = 1.0
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    scale = 1.1
                }
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        SlideInView(delay: 0) {
            Text("Slide In Animation")
                .terminalCard()
                .padding()
        }
        
        FadeInView(delay: 0.2) {
            Text("Fade In Animation")
                .terminalCard()
                .padding()
        }
        
        ScaleInView(delay: 0.4) {
            Text("Scale In Animation")
                .terminalCard()
                .padding()
        }
    }
    .background(Theme.Colors.background)
}
