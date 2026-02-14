//
//  TermsOfServiceView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/4/26.
//

import SwiftUI

/// Terms of Service view
struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Terms of Service")
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Last updated: February 4, 2026")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    
                    Divider()
                        .background(Theme.Colors.border)
                    
                    // Introduction
                    Section {
                        Text("Welcome to Affilia")
                            .font(Theme.Typography.heading)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("These Terms of Service (\"Terms\") govern your access to and use of Affilia, a platform connecting independent developers and designers with clients seeking their services. By accessing or using Affilia, you agree to be bound by these Terms.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                    }
                    
                    // 1. Acceptance of Terms
                    Section {
                        NumberedSectionHeader(number: "1", "Acceptance of Terms")
                        
                        Text("By creating an account, accessing, or using Affilia, you confirm that you:")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        BulletPoint(text: "Are at least 18 years old or the age of majority in your jurisdiction")
                        BulletPoint(text: "Have the legal capacity to enter into binding contracts")
                        BulletPoint(text: "Agree to comply with all applicable laws and regulations")
                        BulletPoint(text: "Will provide accurate and truthful information")
                    }
                    
                    // 2. Account Registration
                    Section {
                        NumberedSectionHeader(number: "2", "Account Registration")
                        
                        Text("To use Affilia, you must create an account by authenticating with X (Twitter) or other supported authentication methods. You agree to:")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        BulletPoint(text: "Provide accurate, current, and complete information")
                        BulletPoint(text: "Maintain the security of your account credentials")
                        BulletPoint(text: "Notify us immediately of any unauthorized access")
                        BulletPoint(text: "Accept responsibility for all activities under your account")
                    }
                    
                    // 3. User Roles and Responsibilities
                    Section {
                        NumberedSectionHeader(number: "3", "User Roles and Responsibilities")
                        
                        Text("Affilia supports two user roles:")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("Builders (Freelancers)")
                                .font(Theme.Typography.body.weight(.semibold))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            BulletPoint(text: "Must accurately represent your skills and experience")
                            BulletPoint(text: "Must deliver services as agreed upon with clients")
                            BulletPoint(text: "Must maintain professional communication")
                            BulletPoint(text: "Are responsible for your own tax obligations")
                        }
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("Clients (Hiring)")
                                .font(Theme.Typography.body.weight(.semibold))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            BulletPoint(text: "Must provide clear project requirements")
                            BulletPoint(text: "Must communicate professionally and respectfully")
                            BulletPoint(text: "Must honor agreed-upon terms and payments")
                            BulletPoint(text: "Must not request work that violates laws or regulations")
                        }
                    }
                    
                    // 4. Platform Usage
                    Section {
                        NumberedSectionHeader(number: "4", "Platform Usage")
                        
                        Text("You agree NOT to:")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        BulletPoint(text: "Use the platform for any illegal or unauthorized purpose")
                        BulletPoint(text: "Harass, abuse, or harm other users")
                        BulletPoint(text: "Post false, misleading, or fraudulent information")
                        BulletPoint(text: "Circumvent platform fees or payment systems")
                        BulletPoint(text: "Scrape, copy, or misuse platform data")
                        BulletPoint(text: "Reverse engineer or attempt to access source code")
                        BulletPoint(text: "Interfere with platform security or functionality")
                    }
                    
                    // 5. Payments and Fees
                    Section {
                        NumberedSectionHeader(number: "5", "Payments and Fees")
                        
                        Text("Affilia may charge platform fees for connecting builders with clients. All fees will be clearly disclosed before transactions. Payment processing is handled by third-party providers, and you agree to comply with their terms.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                        
                        Text("Affilia is not responsible for disputes between builders and clients regarding payment or deliverables. Users are encouraged to establish clear contracts.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                    }
                    
                    // 6. Intellectual Property
                    Section {
                        NumberedSectionHeader(number: "6", "Intellectual Property")
                        
                        BulletPoint(text: "All content, trademarks, and data on Affilia are owned by Affilia or its licensors")
                        BulletPoint(text: "You retain ownership of content you upload or create")
                        BulletPoint(text: "By posting content, you grant Affilia a license to display, distribute, and promote it")
                        BulletPoint(text: "Work created by builders for clients is subject to agreements between parties")
                    }
                    
                    // 7. Disclaimers
                    Section {
                        NumberedSectionHeader(number: "7", "Disclaimers")
                        
                        Text("Affilia is provided \"AS IS\" and \"AS AVAILABLE\" without warranties of any kind. We do not guarantee:")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        BulletPoint(text: "Uninterrupted or error-free service")
                        BulletPoint(text: "The accuracy or reliability of user-generated content")
                        BulletPoint(text: "The quality of work performed by builders")
                        BulletPoint(text: "That users will fulfill their commitments")
                        
                        Text("Affilia acts as a platform connecting users and is not a party to contracts between builders and clients.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                            .padding(.top, Theme.Spacing.sm)
                    }
                    
                    // 8. Limitation of Liability
                    Section {
                        NumberedSectionHeader(number: "8", "Limitation of Liability")
                        
                        Text("To the fullest extent permitted by law, Affilia and its affiliates shall not be liable for:")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        BulletPoint(text: "Indirect, incidental, or consequential damages")
                        BulletPoint(text: "Loss of profits, data, or business opportunities")
                        BulletPoint(text: "Damages arising from user disputes or transactions")
                        BulletPoint(text: "Actions or omissions of other users")
                        
                        Text("Our total liability shall not exceed the fees you paid to Affilia in the past 12 months.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                            .padding(.top, Theme.Spacing.sm)
                    }
                    
                    // 9. Termination
                    Section {
                        NumberedSectionHeader(number: "9", "Termination")
                        
                        Text("We reserve the right to suspend or terminate your account at any time for:")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        BulletPoint(text: "Violation of these Terms")
                        BulletPoint(text: "Fraudulent or illegal activity")
                        BulletPoint(text: "Abuse or harassment of other users")
                        BulletPoint(text: "Any reason at our discretion")
                        
                        Text("You may terminate your account at any time by contacting support.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                            .padding(.top, Theme.Spacing.sm)
                    }
                    
                    // 10. Changes to Terms
                    Section {
                        NumberedSectionHeader(number: "10", "Changes to Terms")
                        
                        Text("We may update these Terms from time to time. We will notify you of material changes by email or through the platform. Continued use after changes constitutes acceptance of the updated Terms.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                    }
                    
                    // 11. Governing Law
                    Section {
                        NumberedSectionHeader(number: "11", "Governing Law")
                        
                        Text("These Terms shall be governed by the laws of the United States. Any disputes shall be resolved in the courts of the applicable jurisdiction.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                    }
                    
                    // 12. Contact
                    Section {
                        NumberedSectionHeader(number: "12", "Contact")
                        
                        Text("If you have questions about these Terms, please contact us at:")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        Link("rob@affilia.io", destination: URL(string: "mailto:rob@affilia.io")!)
                            .font(Theme.Typography.body.weight(.semibold))
                            .foregroundColor(Theme.Colors.accent)
                            .padding(.top, Theme.Spacing.xs)
                    }
                    
                    Spacer(minLength: Theme.Spacing.xl)
                }
                .padding(Theme.Spacing.md)
            }
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Supporting Views

private struct NumberedSectionHeader: View {
    let number: String
    let title: String
    
    init(number: String, _ title: String) {
        self.number = number
        self.title = title
    }
    
    var body: some View {
        Text("\(number). \(title)")
            .font(Theme.Typography.heading)
            .foregroundColor(Theme.Colors.textPrimary)
            .padding(.top, Theme.Spacing.md)
    }
}

private struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Text("•")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.accent)
            
            Text(text)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(4)
        }
        .padding(.leading, Theme.Spacing.sm)
    }
}

#Preview {
    NavigationStack {
        TermsOfServiceView()
    }
}
