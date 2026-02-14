//
//  GigsView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI

struct GigsView: View {
    @StateObject private var gigManager = GigManager.shared
    @State private var selectedCategory: GigCategory?
    @State private var selectedGig: GigListing?

    var filteredGigs: [GigListing] {
        if let category = selectedCategory {
            return gigManager.availableGigs.filter { $0.category == category }
        }
        return gigManager.availableGigs
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        TerminalHeader(title: "Campaign Contracts")

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Theme.Spacing.sm) {
                                FilterChip(
                                    title: "All",
                                    isSelected: selectedCategory == nil,
                                    action: { selectedCategory = nil }
                                )

                                ForEach(GigCategory.allCases, id: \.self) { category in
                                    FilterChip(
                                        title: category.rawValue,
                                        isSelected: selectedCategory == category,
                                        action: { selectedCategory = category }
                                    )
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                        }

                        Text("> \(filteredGigs.count) contract(s) available")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .padding(.horizontal, Theme.Spacing.md)

                        if filteredGigs.isEmpty {
                            EmptyStateView(message: "no campaign contracts found_")
                                .padding(.top, Theme.Spacing.xxl)
                        } else {
                            LazyVStack(spacing: Theme.Spacing.md) {
                                ForEach(filteredGigs) { gig in
                                    GigCard(gig: gig, onViewDetails: {
                                        selectedGig = gig
                                    })
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                        }

                        Spacer(minLength: Theme.Spacing.xl)
                    }
                    .padding(.bottom, Theme.Spacing.md)
                }
            }
            .navigationDestination(item: $selectedGig) { gig in
                GigOfferDetailView(gig: gig)
            }
            .onAppear {
                if gigManager.availableGigs.isEmpty {
                    gigManager.loadGigs()
                }
            }
        }
    }
}

struct GigCard: View {
    let gig: GigListing
    let onViewDetails: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(gig.title)
                .font(Theme.Typography.title)
                .foregroundColor(Theme.Colors.textPrimary)

            HStack(spacing: Theme.Spacing.xs) {
                Text("by")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
                Text(gig.hirerHandle)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.accent)
            }

            Text(gig.description)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(4)
                .padding(.top, Theme.Spacing.xs)

            HStack(spacing: Theme.Spacing.xs) {
                CategoryTag(category: gig.category.rawValue)
                CategoryTag(category: gig.commissionType.rawValue)
            }
            .padding(.top, Theme.Spacing.xs)

            HStack {
                Text(gig.commissionDisplay)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.accent)

                Spacer()

                Text("$\(Int(gig.budget)) pool")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.top, Theme.Spacing.sm)

            TerminalButton("VIEW CONTRACT") {
                onViewDetails()
            }
            .padding(.top, Theme.Spacing.xs)
        }
        .padding(Theme.Spacing.md)
        .terminalCard()
    }
}

#Preview {
    GigsView()
}

