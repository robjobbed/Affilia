# Internal Advertising System - Complete Guide

## Overview

Solomine now has a **complete internal advertising system** where builders can pay to boost their visibility. This creates a **new revenue stream where you keep 100%** of the advertising spend (unlike the 5% platform fee on contracts).

## Revenue Model

### Platform Fees Comparison

| Revenue Stream | Platform Share | Notes |
|----------------|----------------|-------|
| Contract Fees | 5% | From freelancer payments |
| Advertising | **100%** | All ad spend goes to platform |

### Example Revenue

```
Builder pays $149.99 for Premium Boost
├─ Platform keeps: $149.99 (100%)
└─ Cost to platform: ~$0 (digital advertising)

Net profit: $149.99 per boost purchase
```

## Ad Types & Pricing

### 1. Profile Boost ($49.99 - $149.99)
- **Starter Boost**: $49.99/week
  - Top of search results
  - 500+ estimated impressions
- **Pro Boost**: $89.99/2 weeks
  - Featured section + search
  - 2,000+ impressions
- **Premium Boost**: $149.99/month
  - Full featured listing
  - 5,000+ impressions

### 2. Agent Boost ($49.99 - $89.99)
- **Agent Starter**: $49.99/week
  - Agent marketplace top placement
  - 300+ impressions
- **Agent Pro**: $89.99/2 weeks
  - Featured agent listing
  - 1,500+ impressions

### 3. Sponsored Search ($29.99/week)
- Appear at top for specific keywords
- Target skills/categories
- 200+ impressions

### 4. Banner Ads ($149.99/week)
- Display banner on Explore page
- High visibility placement
- 3,000+ impressions

## Features

### For Builders
- ✅ Easy boost packages
- ✅ Custom campaign creation
- ✅ Budget control
- ✅ Pause/resume campaigns
- ✅ Cancel with refund
- ✅ Real-time analytics
- ✅ Performance tracking
- ✅ Featured badges

### For Platform (You)
- ✅ 100% ad revenue
- ✅ Automated campaign management
- ✅ Analytics dashboard
- ✅ Campaign review system
- ✅ Fraud detection ready
- ✅ Revenue tracking
- ✅ Multiple ad formats

## Files Created

### Models
**`ModelsAdvertising.swift`** - Complete ad system models
- `AdCampaign` - Campaign data
- `AdCampaignType` - Profile/Agent/Search/Banner
- `AdPlacement` - Where ads appear
- `AdMetrics` - Performance tracking
- `BoostPackage` - Pre-defined packages
- `AdTargeting` - Audience targeting

### Manager
**`AdvertisingManager.swift`** - Campaign management
- Create/purchase campaigns
- Track impressions/clicks
- Calculate revenue
- Pause/resume/cancel
- Analytics tracking
- Budget management

### Views
**`ViewsBoostProfileView.swift`** - Main boost interface
- Package selection
- Benefits display
- Current campaigns
- Easy purchase flow

**`ViewsPurchaseBoostSheet.swift`** - Purchase & details
- Purchase confirmation
- Payment processing
- Campaign details
- Performance dashboard

## Integration

### Step 1: Add Boost Button to Profile

```swift
// In FreelancerDashboardView or ProfileView
struct MyProfileView: View {
    @State private var showingBoost = false
    
    var body: some View {
        VStack {
            // Profile content...
            
            Button {
                showingBoost = true
            } label: {
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                    Text("Boost Profile")
                        .font(Theme.Typography.body.weight(.bold))
                }
                .foregroundColor(Theme.Colors.background)
                .frame(maxWidth: .infinity)
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.accent)
                .cornerRadius(Theme.CornerRadius.medium)
            }
        }
        .sheet(isPresented: $showingBoost) {
            BoostProfileView()
        }
    }
}
```

### Step 2: Add to Settings/Menu

```swift
// In SettingsView or main menu
NavigationLink {
    BoostProfileView()
} label: {
    SettingsRow(
        icon: "arrow.up.circle.fill",
        title: "Boost Your Profile",
        subtitle: "Get more visibility"
    )
}
```

### Step 3: Integrate with Search/Explore

```swift
// In ExploreView.swift
struct ExploreView: View {
    @StateObject private var adManager = AdvertisingManager.shared
    
    var body: some View {
        ScrollView {
            VStack {
                // Featured (Boosted) Profiles
                if !boostedProfiles.isEmpty {
                    FeaturedSection(profiles: boostedProfiles)
                }
                
                // Regular profiles
                RegularProfileList()
            }
        }
    }
    
    var boostedProfiles: [FreelancerProfile] {
        let boostedIds = adManager.getBoostedProfiles()
        return profiles.filter { boostedIds.contains($0.id) }
    }
}
```

## Pricing Strategy

### Cost Structure

**Cost Per Impression (CPM)**
- Explore Top: $0.05
- Search Results: $0.05
- Agent Marketplace: $0.04
- Featured Section: $0.03

**Cost Per Click (CPC)**
- Explore Top: $0.50
- Search Results: $0.50
- Agent Marketplace: $0.40
- Featured Section: $0.30

### Package Pricing

Packages are priced to provide value while maximizing revenue:

```
Starter ($49.99):
- 500 impressions × $0.05 = $25 cost
- Profit margin: $24.99 (50%)

Pro ($89.99):
- 2,000 impressions × $0.03 = $60 cost
- Profit margin: $29.99 (33%)

Premium ($149.99):
- 5,000 impressions × $0.03 = $150 cost
- Profit margin: ~$0 (volume play)
```

**Note**: These are estimated costs. Actual costs are ~$0 since it's your platform!

## Revenue Projections

### Conservative Estimates

**Assumption**: 10% of builders purchase boosts

```
100 builders on platform
× 10% boost adoption
× $89.99 average package
= $899.90/month

Annual: $10,798.80
```

### Growth Projections

| Builders | Adoption | Avg Package | Monthly | Annual |
|----------|----------|-------------|---------|--------|
| 100 | 10% | $89.99 | $899 | $10,799 |
| 500 | 15% | $89.99 | $6,749 | $80,993 |
| 1,000 | 20% | $89.99 | $17,998 | $215,976 |
| 5,000 | 25% | $89.99 | $112,488 | $1,349,850 |

### Combined Revenue

With both contract fees AND advertising:

```
Platform with 1,000 builders:
├─ Contract fees (5%): ~$50K/year
├─ Advertising (100%): ~$216K/year
└─ Total: $266K/year

At 5,000 builders:
├─ Contract fees (5%): ~$250K/year
├─ Advertising (100%): ~$1.35M/year
└─ Total: $1.6M/year
```

## Ad Delivery System

### How Ads Are Shown

```swift
// 1. User visits Explore page
// 2. System fetches active campaigns
let campaigns = adManager.getActiveCampaigns(for: .exploreTop, limit: 3)

// 3. Display boosted profiles
for campaign in campaigns {
    // Show profile
    // Track impression
    adManager.trackImpression(campaignId: campaign.id, userId: user.id, placement: .exploreTop)
}

// 4. User clicks profile
adManager.trackClick(campaignId: campaign.id, userId: user.id)

// 5. User views full profile
adManager.trackConversion(campaignId: campaign.id, userId: user.id)

// 6. User hires builder
adManager.trackHire(campaignId: campaign.id, contractValue: 5000)
```

### Featured Badge

Show "Featured" badge on boosted profiles:

```swift
struct ProfileCard: View {
    let profile: FreelancerProfile
    let isBoosted: Bool
    
    var body: some View {
        VStack {
            if isBoosted {
                HStack {
                    Image(systemName: "star.fill")
                    Text("FEATURED")
                        .font(Theme.Typography.tiny.weight(.bold))
                }
                .foregroundColor(.yellow)
            }
            
            // Profile content...
        }
    }
}
```

## Analytics & Metrics

### Campaign Performance

Tracked automatically:
- **Impressions**: How many times shown
- **Clicks**: How many times clicked
- **CTR**: Click-through rate
- **Conversions**: Profile views
- **Hires**: Actual contracts
- **Revenue**: Money spent
- **Cost per click**
- **Cost per hire**

### Platform Analytics

Track for business insights:
```swift
// Total ad revenue
adManager.platformAdRevenue

// Revenue by ad type
adManager.revenueByType

// Daily revenue
adManager.dailyRevenue(date: Date())

// Most popular packages
// Average campaign budget
// Conversion rates
```

## Campaign Review System

### Approval Flow

```
1. Builder purchases boost
2. Status: Pending Review
3. Admin reviews campaign
4. Approve or Reject
5. If approved: Status: Active
6. Campaign goes live
```

### Review Criteria

Check for:
- ✅ Profile is complete
- ✅ No inappropriate content
- ✅ Skills are legitimate
- ✅ Portfolio is real
- ✅ X account is verified

### Admin Functions

```swift
// Approve campaign
adManager.approveCampaign(campaignId)

// Reject campaign (with refund)
adManager.rejectCampaign(campaignId, reason: "Incomplete profile")
```

## Targeting System

### Available Targeting

```swift
AdTargeting(
    targetSkills: ["SwiftUI", "iOS"],
    targetBudget: .fiveToTen,
    targetExperience: .senior
)
```

**Target by**:
- Skills/keywords
- Budget range
- Experience level
- Location (future)

### Smart Targeting

Show ads to users more likely to hire:
```swift
// Show iOS developers to users searching "SwiftUI"
// Show expensive profiles to high-budget hirers
// Show senior devs to enterprise clients
```

## Payment Integration

### Apple Pay

```swift
// In AdvertisingManager
private func processPayment(amount: Double, description: String) async throws {
    // Use existing PaymentManager
    let payment = try await PaymentManager.shared.processApplePayPayment(
        amount: amount,
        description: description
    )
    
    // Record transaction
    // Create campaign
}
```

### Refund System

```swift
// Cancel campaign with refund
func cancelCampaign(_ campaignId: UUID) async throws {
    let campaign = getCampaign(campaignId)
    let refund = campaign.budgetRemaining
    
    // Process refund through PaymentManager
    if refund > 0 {
        try await PaymentManager.shared.refund(
            amount: refund,
            reason: "Campaign cancelled"
        )
    }
    
    campaign.status = .cancelled
}
```

## Backend Requirements

### API Endpoints

```
POST   /api/ads/campaigns              - Create campaign
GET    /api/ads/campaigns              - Get user's campaigns
GET    /api/ads/campaigns/:id          - Get campaign details
PUT    /api/ads/campaigns/:id/pause    - Pause campaign
PUT    /api/ads/campaigns/:id/resume   - Resume campaign
DELETE /api/ads/campaigns/:id          - Cancel campaign

POST   /api/ads/impressions            - Track impression
POST   /api/ads/clicks                 - Track click
POST   /api/ads/conversions            - Track conversion

GET    /api/ads/boosted-profiles       - Get boosted profiles
GET    /api/ads/boosted-agents         - Get boosted agents

GET    /api/ads/revenue                - Admin: Revenue stats
```

### Database Schema

```sql
CREATE TABLE ad_campaigns (
    id UUID PRIMARY KEY,
    advertiser_id UUID REFERENCES users(id),
    campaign_type VARCHAR(50),
    placement VARCHAR(100),
    budget DECIMAL(10, 2),
    spent DECIMAL(10, 2) DEFAULT 0,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    status VARCHAR(50),
    targeting JSONB,
    metrics JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE ad_impressions (
    id UUID PRIMARY KEY,
    campaign_id UUID REFERENCES ad_campaigns(id),
    user_id UUID REFERENCES users(id),
    placement VARCHAR(100),
    clicked BOOLEAN DEFAULT FALSE,
    converted BOOLEAN DEFAULT FALSE,
    timestamp TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_campaigns_advertiser ON ad_campaigns(advertiser_id);
CREATE INDEX idx_campaigns_status ON ad_campaigns(status);
CREATE INDEX idx_impressions_campaign ON ad_impressions(campaign_id);
```

## Best Practices

### For You (Platform)

1. **Review campaigns quickly** (< 24 hours)
2. **Monitor for fraud** (click fraud, fake profiles)
3. **A/B test pricing** to maximize revenue
4. **Show value** with detailed analytics
5. **Upsell** from starter to premium packages

### For Builders

1. **Complete profile first** before boosting
2. **Choose right package** based on goals
3. **Monitor performance** and adjust
4. **Time campaigns** for high-traffic periods
5. **Target correctly** for better ROI

## Marketing the Feature

### To Builders

**Pitch**:
"Get 3-5x more client inquiries with Profile Boost. Appear at the top of search results and stand out with a Featured badge."

**Benefits**:
- ✅ More visibility
- ✅ More client inquiries
- ✅ Higher-quality leads
- ✅ Competitive advantage
- ✅ Full control & analytics

### In-App Prompts

Show prompts to encourage boosting:
```swift
// After profile completion
"✨ Your profile looks great! Boost it to get 3x more views"

// After first contract
"🎉 You got your first hire! Want to get even more? Boost your profile"

// Low activity
"📊 Quiet week? Boost your profile to appear at the top of searches"
```

## Future Enhancements

### Phase 2
- [ ] Automated A/B testing
- [ ] Smart bidding (pay per hire)
- [ ] Geographic targeting
- [ ] Time-of-day targeting
- [ ] Retargeting campaigns

### Phase 3
- [ ] Agency accounts (manage multiple builders)
- [ ] White-label advertising platform
- [ ] API for third-party ads
- [ ] Video ads
- [ ] Testimonial showcase ads

## Testing Checklist

### Functionality
- [ ] Purchase boost package
- [ ] See boosted profile at top
- [ ] Track impressions
- [ ] Track clicks
- [ ] View analytics
- [ ] Pause campaign
- [ ] Resume campaign
- [ ] Cancel with refund

### Edge Cases
- [ ] Campaign expires
- [ ] Budget runs out
- [ ] Multiple campaigns
- [ ] Simultaneous boosters
- [ ] Zero impressions
- [ ] Payment failure

### Analytics
- [ ] Metrics update in real-time
- [ ] CTR calculates correctly
- [ ] Revenue tracks accurately
- [ ] Charts display properly

## Success Metrics

Track these KPIs:
- **Boost adoption rate** (% of builders who boost)
- **Average campaign budget**
- **Campaign renewal rate**
- **Builder satisfaction** (did boost help?)
- **Platform ad revenue**
- **ROI for builders** (hires per boost $)

---

## Summary

You now have a **complete internal advertising system**:

✅ Multiple ad types and packages  
✅ Easy purchase flow with Apple Pay  
✅ Real-time analytics dashboard  
✅ Campaign management (pause/resume/cancel)  
✅ **100% revenue** to platform  
✅ Automated impression/click tracking  
✅ Featured badges for boosted profiles  
✅ Professional UI matching your brand  

**Revenue Potential**:
- Immediate: $10K-$20K/year (100-200 builders)
- Growth: $200K-$1.3M/year (1,000-5,000 builders)
- No additional costs (digital advertising on your platform)

**Next Steps**:
1. Add boost button to profile
2. Integrate boosted profiles in Explore
3. Test purchase flow
4. Launch to beta users
5. Scale! 🚀

Welcome to your new revenue stream! 💰✨
