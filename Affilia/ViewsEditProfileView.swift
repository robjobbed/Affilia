//
//  EditProfileView.swift
//  Affilia
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var hourlyRate: String = ""
    @State private var skills: [String] = []
    @State private var newSkill: String = ""
    @State private var availability: AvailabilityStatus = .openToWork
    @State private var showingSkillInput = false
    @State private var isSaving = false
    
    let availabilityOptions = AvailabilityStatus.allCases
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        // X Profile Info (Read-only)
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            SectionHeader("X Profile")
                            
                            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                                HStack {
                                    Image(systemName: "bird")
                                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                                        .foregroundColor(Theme.Colors.accent)
                                    
                                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                        Text("@\(authManager.xProfile?.username ?? "username")")
                                            .font(Theme.Typography.body)
                                            .foregroundColor(Theme.Colors.accent)
                                        
                                        Text("\(authManager.xProfile?.followers ?? 0) followers")
                                            .font(Theme.Typography.caption)
                                            .foregroundColor(Theme.Colors.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if authManager.xProfile?.verified == true {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(Theme.Colors.accent)
                                    }
                                }
                                
                                Text("> synced from your X account")
                                    .font(Theme.Typography.tiny)
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            .padding(Theme.Spacing.md)
                            .terminalCard()
                            .padding(.horizontal, Theme.Spacing.md)
                        }
                        
                        // Display Name
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            SectionHeader("Display Name")
                            
                            TerminalTextField(
                                placeholder: "Your display name",
                                text: $displayName
                            )
                            .padding(.horizontal, Theme.Spacing.md)
                        }
                        
                        // Bio
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            SectionHeader("Bio")
                            
                            TerminalTextEditor(
                                placeholder: "Tell people about yourself...",
                                text: $bio
                            )
                            .frame(height: 120)
                            .padding(.horizontal, Theme.Spacing.md)
                        }
                        
                        // Skills
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            HStack {
                                SectionHeader("Skills")
                                Spacer()
                                Button(action: { showingSkillInput.toggle() }) {
                                    Image(systemName: showingSkillInput ? "xmark" : "plus")
                                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                                        .foregroundColor(Theme.Colors.accent)
                                }
                                .padding(.trailing, Theme.Spacing.md)
                            }
                            
                            if showingSkillInput {
                                HStack(spacing: Theme.Spacing.sm) {
                                    TerminalTextField(
                                        placeholder: "Add skill",
                                        text: $newSkill
                                    )
                                    
                                    Button(action: addSkill) {
                                        Text("ADD")
                                            .font(Theme.Typography.caption)
                                            .foregroundColor(Theme.Colors.background)
                                            .padding(.horizontal, Theme.Spacing.md)
                                            .padding(.vertical, Theme.Spacing.sm)
                                            .background(Theme.Colors.accent)
                                            .cornerRadius(Theme.CornerRadius.small)
                                    }
                                }
                                .padding(.horizontal, Theme.Spacing.md)
                            }
                            
                            if skills.isEmpty {
                                Text("> no skills added yet")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .padding(Theme.Spacing.md)
                                    .terminalCard()
                                    .padding(.horizontal, Theme.Spacing.md)
                            } else {
                                SkillsGridView(skills: $skills, editable: true)
                                    .padding(.horizontal, Theme.Spacing.md)
                            }
                        }
                        
                        // Hourly Rate (if builder)
                        if authManager.currentUser?.role == .builder {
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                SectionHeader("Hourly Rate")
                                
                                HStack {
                                    Text("$")
                                        .font(Theme.Typography.body)
                                        .foregroundColor(Theme.Colors.accent)
                                    
                                    TerminalTextField(
                                        placeholder: "150",
                                        text: $hourlyRate
                                    )
                                    .keyboardType(.numberPad)
                                    
                                    Text("/hour")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                }
                                .padding(.horizontal, Theme.Spacing.md)
                            }
                            
                            // Availability
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                SectionHeader("Availability")
                                
                                VStack(spacing: Theme.Spacing.sm) {
                                    ForEach(availabilityOptions, id: \.self) { option in
                                        Button(action: {
                                            availability = option
                                        }) {
                                            HStack {
                                                Text(option.rawValue)
                                                    .font(Theme.Typography.caption)
                                                    .foregroundColor(
                                                        availability == option
                                                            ? Theme.Colors.background
                                                            : Theme.Colors.accent
                                                    )
                                                
                                                Spacer()
                                                
                                                if availability == option {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                                        .foregroundColor(Theme.Colors.background)
                                                }
                                            }
                                            .padding(Theme.Spacing.sm)
                                            .background(
                                                availability == option
                                                    ? Theme.Colors.accent
                                                    : Color.clear
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                                    .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                                            )
                                            .cornerRadius(Theme.CornerRadius.medium)
                                        }
                                    }
                                }
                                .padding(.horizontal, Theme.Spacing.md)
                            }
                        }
                        
                        // Save Button
                        VStack(spacing: Theme.Spacing.sm) {
                            if isSaving {
                                LoadingIndicator()
                                    .padding(.vertical, Theme.Spacing.md)
                            } else {
                                Button(action: saveProfile) {
                                    Text("SAVE PROFILE")
                                        .font(Theme.Typography.body)
                                        .foregroundColor(Theme.Colors.background)
                                        .padding(.vertical, Theme.Spacing.md)
                                        .frame(maxWidth: .infinity)
                                        .background(Theme.Colors.accent)
                                        .cornerRadius(Theme.CornerRadius.medium)
                                }
                                
                                Button(action: { dismiss() }) {
                                    Text("CANCEL")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.accentSecondary)
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.vertical, Theme.Spacing.lg)
                    }
                    .padding(.vertical, Theme.Spacing.md)
                }
            }
            .navigationTitle("EDIT PROFILE")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("EDIT PROFILE")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.accent)
                }
            }
            .toolbarBackground(Theme.Colors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            loadCurrentProfile()
        }
    }
    
    private func loadCurrentProfile() {
        if let profile = authManager.currentUser?.freelancerProfile {
            displayName = profile.displayName
            bio = profile.bio
            hourlyRate = profile.hourlyRate != nil ? "\(Int(profile.hourlyRate!))" : ""
            skills = profile.skills
            availability = profile.availability
        }
    }
    
    private func addSkill() {
        let trimmedSkill = newSkill.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSkill.isEmpty else { return }
        guard !skills.contains(trimmedSkill) else { return }
        
        skills.append(trimmedSkill)
        newSkill = ""
        showingSkillInput = false
    }
    
    private func saveProfile() {
        isSaving = true
        
        // Simulate save delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Update the user's profile
            if var user = authManager.currentUser {
                var profile = user.freelancerProfile ?? FreelancerProfile(
                    xUsername: authManager.xProfile?.username ?? "",
                    displayName: displayName,
                    bio: bio,
                    skills: skills
                )
                
                profile.displayName = displayName
                profile.bio = bio
                profile.skills = skills
                profile.hourlyRate = Double(hourlyRate)
                profile.availability = availability
                
                user.freelancerProfile = profile
                authManager.currentUser = user
                
                print("✅ Profile updated:")
                print("   - Display Name: \(displayName)")
                print("   - Bio: \(bio)")
                print("   - Skills: \(skills.joined(separator: ", "))")
                if let rate = Double(hourlyRate) {
                    print("   - Hourly Rate: $\(Int(rate))")
                }
                print("   - Availability: \(availability.rawValue)")
            }
            
            isSaving = false
            dismiss()
        }
    }
}

struct SkillsGridView: View {
    @Binding var skills: [String]
    var editable: Bool = false
    
    var body: some View {
        FlowLayout(spacing: Theme.Spacing.sm) {
            ForEach(skills, id: \.self) { skill in
                HStack(spacing: Theme.Spacing.xs) {
                    Text(skill)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.accent)
                    
                    if editable {
                        Button(action: {
                            skills.removeAll { $0 == skill }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(Theme.Colors.accentSecondary)
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, Theme.Spacing.xs)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.thin)
                )
            }
        }
    }
}

struct TerminalTextEditor: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text("> \(placeholder)")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, Theme.Spacing.sm + 2)
            }
            
            TextEditor(text: $text)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textPrimary)
                .scrollContentBackground(.hidden)
                .background(Theme.Colors.surface)
                .padding(Theme.Spacing.xs)
        }
        .background(Theme.Colors.surface)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
        )
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthenticationManager.shared)
}
