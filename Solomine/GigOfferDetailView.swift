import SwiftUI

@MainActor
struct GigOfferDetailView: View {
    let gig: GigListing
    
    var body: some View {
        GigDetailView(gig: gig)
    }
}

#Preview {
    GigOfferDetailView(gig: GigListing(
        id: UUID(),
        hirerId: UUID(),
        hirerName: "Preview User",
        hirerHandle: "@preview",
        freelancerId: nil,
        title: "Preview Gig",
        description: "This is a preview gig for testing the detail view.",
        requirements: ["SwiftUI", "Combine"],
        budget: 999,
        estimatedHours: 6,
        category: .content,
        urgency: .normal,
        postedDate: Date().addingTimeInterval(-600),
        applicants: 1
    ))
}
