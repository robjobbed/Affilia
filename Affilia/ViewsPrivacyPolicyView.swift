//
//  PrivacyPolicyView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/4/26.
//

import SwiftUI

/// Privacy Policy view
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Privacy Policy")
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
                        Text("Your Privacy Matters")
                            .font(Theme.Typography.heading)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("At Affilia, we are committed to protecting your privacy and ensuring transparency about how we collect, use, and safeguard your personal information. This Privacy Policy explains our practices regarding your data when you use our platform.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                    }
                    
                    // 1. Information We Collect
                    Section {
                        NumberedSectionHeader(number: "1", "Information We Collect")
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            SubsectionHeader(title: "1.1 Information You Provide")
                            
                            Text("When you create an account or use Affilia, you may provide:")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            BulletPoint(text: "Profile information from X (Twitter) including username, display name, profile photo, bio, and follower counts")
                            BulletPoint(text: "Email address")
                            BulletPoint(text: "Skills, portfolio links, and professional information")
                            BulletPoint(text: "Project requirements and descriptions")
                            BulletPoint(text: "Messages and communications with other users")
                            BulletPoint(text: "Payment information (processed securely by third-party providers)")
                            
                            SubsectionHeader(title: "1.2 Automatically Collected Information")
                            
                            Text("We automatically collect certain information when you use Affilia:")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            BulletPoint(text: "Device information (model, operating system, unique identifiers)")
                            BulletPoint(text: "Usage data (features accessed, time spent, interactions)")
                            BulletPoint(text: "Log data (IP address, browser type, access times)")
                            BulletPoint(text: "Location data (if you grant permission)")
                            
                            SubsectionHeader(title: "1.3 Information from Third Parties")
                            
                            BulletPoint(text: "Public profile data from X (Twitter) when you authenticate")
                            BulletPoint(text: "Public repository data from GitHub (if you link your account)")
                            BulletPoint(text: "Payment processing information from Stripe or other payment providers")
                        }
                    }
                    
                    // 2. How We Use Your Information
                    Section {
                        NumberedSectionHeader(number: "2", "How We Use Your Information")
                        
                        Text("We use your information to:")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        BulletPoint(text: "Provide, maintain, and improve Affilia services")
                        BulletPoint(text: "Create and manage your account")
                        BulletPoint(text: "Connect builders with clients based on skills and requirements")
                        BulletPoint(text: "Process payments and transactions")
                        BulletPoint(text: "Send notifications about platform activity and updates")
                        BulletPoint(text: "Respond to your support requests")
                        BulletPoint(text: "Prevent fraud, abuse, and security incidents")
                        BulletPoint(text: "Analyze usage patterns to improve user experience")
                        BulletPoint(text: "Comply with legal obligations")
                    }
                    
                    // 3. How We Share Your Information
                    Section {
                        NumberedSectionHeader(number: "3", "How We Share Your Information")
                        
                        Text("We do not sell your personal information. We may share your information in the following circumstances:")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            SubsectionHeader(title: "3.1 With Other Users")
                            
                            BulletPoint(text: "Your profile information is visible to other users on the platform")
                            BulletPoint(text: "Clients can see builder profiles, skills, and social links")
                            BulletPoint(text: "Messages and project communications are shared between parties")
                            
                            SubsectionHeader(title: "3.2 With Service Providers")
                            
                            BulletPoint(text: "Cloud hosting providers (for data storage)")
                            BulletPoint(text: "Payment processors (for transaction handling)")
                            BulletPoint(text: "Analytics providers (to understand usage patterns)")
                            BulletPoint(text: "Email service providers (for notifications)")
                            
                            SubsectionHeader(title: "3.3 For Legal Reasons")
                            
                            BulletPoint(text: "To comply with laws, regulations, or legal requests")
                            BulletPoint(text: "To protect rights, property, or safety of Affilia or users")
                            BulletPoint(text: "To enforce our Terms of Service")
                            BulletPoint(text: "In connection with a merger, acquisition, or sale of assets")
                        }
                    }
                    
                    // 4. Data Retention
                    Section {
                        NumberedSectionHeader(number: "4", "Data Retention")
                        
                        Text("We retain your information for as long as necessary to provide our services and fulfill the purposes described in this policy. When you delete your account, we will delete or anonymize your personal information, except where we must retain it for legal or security purposes.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                    }
                    
                    // 5. Your Rights and Choices
                    Section {
                        NumberedSectionHeader(number: "5", "Your Rights and Choices")
                        
                        Text("You have the following rights regarding your data:")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        BulletPoint(text: "Access: Request a copy of your personal information")
                        BulletPoint(text: "Correction: Update or correct inaccurate information")
                        BulletPoint(text: "Deletion: Request deletion of your account and data")
                        BulletPoint(text: "Portability: Receive your data in a machine-readable format")
                        BulletPoint(text: "Object: Object to certain processing activities")
                        BulletPoint(text: "Opt-out: Unsubscribe from marketing communications")
                        
                        Text("To exercise these rights, contact us at rob@affilia.io")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                            .padding(.top, Theme.Spacing.sm)
                    }
                    
                    // 6. Security
                    Section {
                        NumberedSectionHeader(number: "6", "Security")
                        
                        Text("We implement industry-standard security measures to protect your information, including:")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        BulletPoint(text: "Encryption of data in transit and at rest")
                        BulletPoint(text: "Secure authentication with OAuth 2.0")
                        BulletPoint(text: "Regular security audits and monitoring")
                        BulletPoint(text: "Access controls and authentication requirements")
                        
                        Text("However, no system is completely secure. We cannot guarantee absolute security of your data.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                            .padding(.top, Theme.Spacing.sm)
                    }
                    
                    // 7. Children's Privacy
                    Section {
                        NumberedSectionHeader(number: "7", "Children's Privacy")
                        
                        Text("Affilia is not intended for users under the age of 18. We do not knowingly collect information from children. If we learn that we have collected information from a child under 18, we will delete it promptly.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                    }
                    
                    // 8. International Data Transfers
                    Section {
                        NumberedSectionHeader(number: "8", "International Data Transfers")
                        
                        Text("Your information may be transferred to and processed in countries other than your country of residence. We ensure appropriate safeguards are in place to protect your data in accordance with this Privacy Policy.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                    }
                    
                    // 9. Third-Party Links
                    Section {
                        NumberedSectionHeader(number: "9", "Third-Party Links")
                        
                        Text("Affilia may contain links to third-party websites or services (such as X, GitHub, or user portfolio sites). We are not responsible for the privacy practices of these third parties. We encourage you to review their privacy policies.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                    }
                    
                    // 10. Changes to Privacy Policy
                    Section {
                        NumberedSectionHeader(number: "10", "Changes to This Privacy Policy")
                        
                        Text("We may update this Privacy Policy from time to time. We will notify you of material changes by email or through the platform. The \"Last updated\" date at the top indicates when the policy was last revised.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                    }
                    
                    // 11. California Privacy Rights
                    Section {
                        NumberedSectionHeader(number: "11", "California Privacy Rights (CCPA)")
                        
                        Text("If you are a California resident, you have additional rights under the California Consumer Privacy Act (CCPA):")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        BulletPoint(text: "Right to know what personal information is collected")
                        BulletPoint(text: "Right to know if personal information is sold or disclosed")
                        BulletPoint(text: "Right to opt-out of sale of personal information (we do not sell)")
                        BulletPoint(text: "Right to deletion of personal information")
                        BulletPoint(text: "Right to non-discrimination for exercising CCPA rights")
                    }
                    
                    // 12. GDPR Rights (European Users)
                    Section {
                        NumberedSectionHeader(number: "12", "GDPR Rights (European Users)")
                        
                        Text("If you are in the European Economic Area (EEA), you have rights under the General Data Protection Regulation (GDPR):")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        BulletPoint(text: "Right to access your personal data")
                        BulletPoint(text: "Right to rectification of inaccurate data")
                        BulletPoint(text: "Right to erasure (\"right to be forgotten\")")
                        BulletPoint(text: "Right to restrict processing")
                        BulletPoint(text: "Right to data portability")
                        BulletPoint(text: "Right to object to processing")
                        BulletPoint(text: "Right to withdraw consent")
                    }
                    
                    // 13. Contact Us
                    Section {
                        NumberedSectionHeader(number: "13", "Contact Us")
                        
                        Text("If you have questions, concerns, or requests regarding this Privacy Policy or your data, please contact us at:")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        Link("rob@affilia.io", destination: URL(string: "mailto:rob@affilia.io")!)
                            .font(Theme.Typography.body.weight(.semibold))
                            .foregroundColor(Theme.Colors.accent)
                            .padding(.top, Theme.Spacing.xs)
                        
                        Text("We will respond to your request within 30 days.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .padding(.top, Theme.Spacing.sm)
                    }
                    
                    Spacer(minLength: Theme.Spacing.xl)
                }
                .padding(Theme.Spacing.md)
            }
        }
        .navigationTitle("Privacy Policy")
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

private struct SubsectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(Theme.Typography.body.weight(.semibold))
            .foregroundColor(Theme.Colors.textPrimary)
            .padding(.top, Theme.Spacing.sm)
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
        PrivacyPolicyView()
    }
}
