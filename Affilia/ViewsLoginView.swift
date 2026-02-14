//
//  LoginView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct LoginView: View {
    @State private var authManager = AuthenticationManager.shared
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: Theme.Spacing.xl) {
                Spacer()
                
                // Logo/Branding
                VStack(spacing: Theme.Spacing.md) {
                    Text("AFFILIA")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.Colors.accent)
                        .kerning(4)
                    
                    Text("> affiliate network for brands + partners")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                // Authentication section
                VStack(spacing: Theme.Spacing.lg) {
                    if isLoading {
                        LoadingIndicator()
                            .padding(.vertical, Theme.Spacing.xxl)
                    } else {
                        VStack(spacing: Theme.Spacing.sm) {
                            // X (Twitter) Login Button
                            Button(action: {
                                isLoading = true
                                authManager.signInWithX()
                                // Reset loading after delay (in production, handle in callback)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isLoading = false
                                }
                            }) {
                                HStack(spacing: Theme.Spacing.sm) {
                                    Image(systemName: "bird")
                                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    
                                    Text("SIGN IN WITH X")
                                        .font(Theme.Typography.body)
                                }
                                .foregroundColor(Theme.Colors.background)
                                .padding(.vertical, Theme.Spacing.md)
                                .frame(maxWidth: .infinity)
                                .background(Theme.Colors.accent)
                                .cornerRadius(Theme.CornerRadius.medium)
                            }
                            
                            // Divider
                            HStack(spacing: Theme.Spacing.sm) {
                                Rectangle()
                                    .fill(Theme.Colors.border)
                                    .frame(height: 1)
                                
                                Text("OR")
                                    .font(Theme.Typography.tiny)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                Rectangle()
                                    .fill(Theme.Colors.border)
                                    .frame(height: 1)
                            }
                            
                            // GitHub Login Button
                            Button(action: {
                                isLoading = true
                                authManager.linkGitHub()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isLoading = false
                                }
                            }) {
                                HStack(spacing: Theme.Spacing.sm) {
                                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    
                                    Text("SIGN IN WITH GITHUB")
                                        .font(Theme.Typography.body)
                                }
                                .foregroundColor(Theme.Colors.accent)
                                .padding(.vertical, Theme.Spacing.md)
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                        .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                                )
                                .cornerRadius(Theme.CornerRadius.medium)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.xl)
                    }
                    
                    // Error message
                    if let error = authManager.authenticationError {
                        Text("> error: \(error)")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.accentSecondary)
                            .padding(Theme.Spacing.md)
                            .terminalCard()
                            .padding(.horizontal, Theme.Spacing.md)
                    }
                }
                
                Spacer()
                
                // Footer
                VStack(spacing: Theme.Spacing.xs) {
                    Text("BY SIGNING IN YOU AGREE TO OUR")
                        .font(Theme.Typography.tiny)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    HStack(spacing: Theme.Spacing.xs) {
                        Text("TERMS")
                            .font(Theme.Typography.tiny)
                            .foregroundColor(Theme.Colors.accent)
                        
                        Text("AND")
                            .font(Theme.Typography.tiny)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        Text("PRIVACY POLICY")
                            .font(Theme.Typography.tiny)
                            .foregroundColor(Theme.Colors.accent)
                    }
                }
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    LoginView()
}
