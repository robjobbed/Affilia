# About Section Implementation

## Overview
The About section in SettingsView now includes comprehensive legal documentation and support features.

## Components Created

### 1. Terms of Service (`TermsOfServiceView.swift`)
A comprehensive Terms of Service document covering:
- Acceptance of Terms
- Account Registration
- User Roles and Responsibilities (Builders & Clients)
- Platform Usage Rules
- Payments and Fees
- Intellectual Property
- Disclaimers and Limitations of Liability
- Termination Policy
- Governing Law
- Contact Information

**Key Features:**
- Clean, scrollable interface with organized sections
- Numbered sections for easy reference
- Bullet points for clarity
- Consistent styling with the app's theme
- Clickable email link for support (rob@solomine.io)

### 2. Privacy Policy (`PrivacyPolicyView.swift`)
A detailed Privacy Policy explaining data practices:
- Information Collection (User-provided, Automatic, Third-party)
- How Information is Used
- Information Sharing Practices
- Data Retention Policy
- User Rights and Choices
- Security Measures
- Children's Privacy Protection
- International Data Transfers
- Third-Party Links
- California Privacy Rights (CCPA)
- GDPR Rights (European Users)
- Contact Information

**Key Features:**
- Comprehensive coverage of privacy practices
- Subsections for clarity (1.1, 1.2, etc.)
- CCPA and GDPR compliance information
- User rights clearly outlined
- 30-day response commitment

### 3. Contact Support (`ContactSupportView.swift`)
An interactive support contact view with:
- Direct email link to rob@solomine.io
- Pre-categorized support topics:
  - Account Issues
  - Payment Questions
  - Report a Problem
  - Report Abuse
  - Feature Request
  - General Question
- Expected response time information (24-48 hours)

**Key Features:**
- One-tap email composition with pre-filled subjects
- Beautiful icon-based UI
- Falls back gracefully if mail isn't configured
- Alert system for error handling
- Clean, accessible design

## Integration

The SettingsView has been updated to include NavigationLinks to all three views:
- Terms of Service → `TermsOfServiceView()`
- Privacy Policy → `PrivacyPolicyView()`
- Contact Support → `ContactSupportView()`

Each link uses a consistent icon and includes a chevron indicator for navigation.

## Design Principles

All views follow these design principles:
1. **Consistency**: Use of Theme system for colors, typography, and spacing
2. **Readability**: Proper line spacing, section headers, and hierarchy
3. **Accessibility**: Clear navigation, semantic structure, and contrast
4. **Scannability**: Bullet points, numbered sections, and subsections
5. **Professionalism**: Legal language balanced with user-friendly explanations

## Contact Information

All documents reference the support email: **rob@solomine.io**

## Last Updated

All documents are dated: **February 4, 2026**

## Future Enhancements

Consider adding:
- In-app FAQ section
- Chat support integration
- Copy-to-clipboard functionality for legal text
- PDF export of Terms/Privacy
- Localization for international users
- Version history for Terms/Privacy updates
