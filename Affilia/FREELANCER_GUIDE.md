# Freelancer (Vibe Coder) Features Guide

## 🎯 Complete Freelancer Control Panel

Freelancers now have a comprehensive dashboard to manage their business on Affilia.

### 📊 Dashboard Tabs

#### 1. **Overview Tab**
The main dashboard showing:
- **Stats Cards**:
  - Active Contracts (number of ongoing projects)
  - This Month's Earnings
  - Total Lifetime Earnings
  - Pending Payments

- **Quick Actions**:
  - Update Pricing (jump to pricing editor)
  - Edit Profile (update skills/portfolio)
  - View Analytics (performance metrics)

- **Recent Activity Feed**:
  - Milestones completed
  - Payments received
  - New contracts signed
  - With timestamps

#### 2. **Contracts Tab**
Manage all contracts in one place:
- **Contract List** with filters:
  - All Contracts
  - Active Only
  - Pending Signature
  - Completed

- **Each Contract Card Shows**:
  - Project title
  - Status badge (Draft, Active, Completed, etc.)
  - Contract value (what hirer pays)
  - Your earnings (after 5% platform fee)
  - Milestone progress bar
  - Completion percentage
  - Quick "View Contract" button

- **Empty State**: Friendly message when no contracts yet

#### 3. **Earnings Tab**
Complete financial overview:
- **Summary Cards**:
  - Total Lifetime Earnings (after platform fee)
  - This Month's Earnings
  - Last Month's Earnings
  - Pending Payments (from incomplete milestones)

- **Payment History**:
  - Chronological list of all payments
  - Project name
  - Amount received
  - Payment date
  - Scrollable history

#### 4. **Pricing Tab** ⭐ NEW
Full control over your rates:

##### **Hourly Rate**
- Set your hourly price
- Real-time calculation showing what you earn after 5% fee
- Example:
  ```
  You set: $150/hour
  Platform fee (5%): -$7.50/hour
  You earn: $142.50/hour
  ```

##### **Project Minimum**
- Set minimum for project-based work
- Protects you from underpriced projects
- Real-time calculation
- Example:
  ```
  You set: $5,000 minimum
  Platform fee (5%): -$250
  You earn: $4,750 minimum
  ```

##### **Availability Status**
Three options with descriptions:
1. **OPEN TO WORK**
   - "Available for new projects"
   - Visible to all hirers
   - Appear in search results

2. **BOOKED**
   - "Not taking new work"
   - Profile visible but marked as unavailable
   - Hirers can still bookmark you

3. **SELECTIVE**
   - "Only certain projects"
   - You'll review proposals case-by-case
   - Good for high-demand freelancers

## 💰 How Freelancer Pricing Works

### Hourly Rate
- **You set**: Your hourly price (e.g., $150/hour)
- **Platform fee**: Automatically calculated (5%)
- **You earn**: 95% of your rate ($142.50/hour)
- **Displayed to hirers**: Your full rate ($150/hour)
- **Benefit**: Transparent pricing, competitive in marketplace

### Project Minimum
- **Purpose**: Prevent low-value projects
- **You set**: Minimum you'll accept (e.g., $5,000)
- **Platform fee**: 5% deducted from final amount
- **You earn**: 95% of minimum ($4,750)
- **Displayed to hirers**: Your full minimum ($5,000)
- **Benefit**: Ensures your time is valued

### Dynamic Display
When hirers create contracts:
- They see your rates on your profile
- Can choose hourly or project-based
- Platform calculates totals automatically
- Clear breakdown shown to both parties

## 📋 Contract Management Features

### Contract Status Flow
```
Draft → Pending Signature → Active → Completed
```

### What Freelancers See Per Contract:
1. **Project Details**
   - Title and description
   - Total contract value
   - What YOU will earn (after fee)
   - Payment structure (upfront/milestones/after)

2. **Milestone Tracking**
   - Visual progress bar
   - X/Y milestones completed
   - Amount per milestone
   - Payment status per milestone

3. **Actions**
   - View full contract
   - Mark milestone complete
   - Request payment
   - Dispute resolution (if needed)

## 🎨 UI Features

### Visual Stats
- **Color-coded badges**:
  - Active contracts: Green
  - Pending: Amber
  - Completed: Green
  - Disputed: Red

- **Progress Bars**:
  - Milestone completion
  - Visual percentage
  - Animated fills

### Quick Navigation
- Tab-based navigation
- Icon + label for clarity
- Persistent across sessions

### Real-Time Updates
- Earnings calculations update as you type
- Platform fee shown immediately
- No surprises - everything transparent

## 🔢 Example Scenarios

### Scenario 1: Hourly Freelancer
```
Your Rate: $200/hour
Project: 100 hours
Contract Value: $20,000
Platform Fee (5%): $1,000
You Earn: $19,000

Displayed in Dashboard:
- Contract Value: $20,000
- You Receive: $19,000
- Status: Active
- Milestones: Based on hours logged
```

### Scenario 2: Project-Based Freelancer
```
Your Minimum: $10,000
Project: Custom iOS App
Contract Value: $50,000
Platform Fee (5%): $2,500
You Earn: $47,500

Payment Structure: 3 Milestones
- Milestone 1 (33%): $16,500 → You get $15,675
- Milestone 2 (34%): $17,000 → You get $16,150  
- Milestone 3 (33%): $16,500 → You get $15,675

Dashboard Shows:
- Total Earnings: $47,500
- Milestone 1: Paid ✅
- Milestone 2: In Progress 🕐
- Milestone 3: Pending ⏸️
```

### Scenario 3: High-Volume Freelancer
```
Monthly Stats:
- 5 Active Contracts
- 12 Milestones Completed
- $45,000 Earned This Month
- $250,000 Lifetime Earnings
- 3 Pending Payments: $12,500

Dashboard Overview:
Shows all stats at a glance
Quick actions to common tasks
Recent activity feed
Filter contracts by status
```

## 🎯 Integration Points

### With Profile View
- Pricing settings sync to public profile
- Hirers see your rates when browsing
- Availability status updates in real-time

### With Messages
- Chat with hirers about contracts
- Send payment requests directly in chat
- Contract creation from conversation

### With Payments
- Apple Pay integration
- Automatic fee calculation
- Transparent breakdowns
- Payment history tracking

## 🚀 Implementation Status

### ✅ Completed
- [x] Full dashboard UI with 4 tabs
- [x] Pricing editor (hourly + project minimum)
- [x] Availability status selector
- [x] Contract list and management
- [x] Earnings tracking
- [x] Real-time fee calculations
- [x] Visual stats and progress bars
- [x] Payment history display
- [x] Role-based dashboard routing

### ⏳ Backend Integration Needed
- [ ] Save pricing to database
- [ ] Load contracts from API
- [ ] Real payment processing
- [ ] Analytics data collection
- [ ] Push notifications for new contracts

## 📱 User Experience Flow

### For New Freelancers
1. **Sign up** with X account
2. **Choose role**: "I BUILD"
3. **Set up pricing**:
   - Navigate to Dashboard → Pricing tab
   - Enter hourly rate
   - Set project minimum
   - Choose availability status
   - Save settings
4. **Build profile**:
   - Add skills
   - Upload portfolio projects
   - Write bio
5. **Start receiving contracts**!

### For Active Freelancers
1. **Check Dashboard** daily
   - See new contract requests
   - Track milestone progress
   - Monitor earnings
2. **Manage Contracts**:
   - View all active work
   - Mark milestones complete
   - Request payments
3. **Update Pricing** as needed:
   - Adjust rates based on demand
   - Change availability
   - Set minimums

### For High-Earning Freelancers
1. **Analytics at a Glance**:
   - Total lifetime earnings
   - Monthly trends
   - Contract velocity
2. **Smart Filtering**:
   - Focus on active work
   - Archive completed projects
   - Track pending payments
3. **Quick Actions**:
   - Update availability when booked
   - Raise rates when in demand
   - Manage multiple contracts efficiently

## 💡 Pro Tips for Freelancers

### Pricing Strategy
1. **Start Competitive**: Set rates 10-20% below market to build reputation
2. **Increase Gradually**: Raise rates 10-15% every 5-10 completed projects
3. **Premium Pricing**: Once established, charge premium rates for quality

### Availability Management
- Set to "BOOKED" when at capacity
- Use "SELECTIVE" to filter low-value inquiries
- "OPEN TO WORK" attracts most opportunities

### Contract Management
- Complete milestones promptly
- Request payment immediately after completion
- Keep communication clear in chat
- Build reputation with on-time delivery

### Earnings Optimization
- Take multiple small contracts vs. one large
- Milestone-based payments provide cash flow
- Request upfront payments when possible
- Track which project types earn most

## 🔐 Security & Privacy

### What's Protected
- ✅ Payment information (Apple Pay)
- ✅ Contract details (encrypted)
- ✅ Earnings data (private)
- ✅ Client information (confidential)

### What's Visible
- ✅ Your public rates (to hirers)
- ✅ Availability status
- ✅ Portfolio and skills
- ✅ Reputation score

## 📞 Support

For freelancer-specific questions:
- **Pricing Help**: pricing@affilia.dev
- **Contract Issues**: contracts@affilia.dev
- **Payment Problems**: payments@affilia.dev
- **General Support**: support@affilia.dev

---

**Last Updated**: February 3, 2026  
**Version**: 2.0  
**Platform Fee**: 5% (deducted from your earnings)
