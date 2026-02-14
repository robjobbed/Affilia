# Apple Pay Integration Setup Guide

## Overview

Solomine now includes full Apple Pay integration for hiring freelancers. Clients can securely pay freelancers directly through Apple Pay with a 5% platform fee automatically calculated.

## Files Added

1. **PaymentManager.swift** - Handles all Apple Pay logic and payment processing
2. **HireFreelancerView.swift** - Complete payment flow UI with terminal aesthetic
3. **AvatarView.swift** - Replaced emoji avatars with clean initial-based avatars

## Required Setup in Xcode

### 1. Add PassKit Framework
- Open your Xcode project
- Select your target → "Signing & Capabilities"
- Click "+ Capability"
- Add "Apple Pay"

### 2. Configure Merchant ID
You need to create a Merchant ID in your Apple Developer account:

1. Go to https://developer.apple.com/account/resources/identifiers/list/merchant
2. Click "+" to create a new Merchant ID
3. Use format: `merchant.com.solomine.payments` (or your own)
4. Once created, go back to Xcode → Signing & Capabilities → Apple Pay
5. Add your Merchant ID to the list

### 3. Update PaymentManager.swift
Replace this line in `PaymentManager.swift`:
```swift
request.merchantIdentifier = "merchant.com.solomine.payments"
```
With your actual Merchant ID from step 2.

### 4. Testing Apple Pay

#### In Simulator:
- Open Settings app → Wallet & Apple Pay
- Add a test card
- Use test card numbers provided by Apple (search "Apple Pay test cards")

#### On Device:
- Use Apple Pay with real cards
- In sandbox/development mode, payments won't actually charge

## Features Implemented

### Payment Flow
1. User taps "HIRE NOW" on freelancer profile
2. Payment sheet opens with:
   - Freelancer info with avatar
   - Quick select amounts (based on hourly rate or project pricing)
   - Custom amount input
   - Project description field (required)
   - Payment breakdown showing:
     - Payment to freelancer
     - 5% platform fee
     - Total amount
   - Apple Pay button

3. User taps "PAY WITH APPLE PAY"
4. Native Apple Pay sheet appears
5. User authenticates (Face ID / Touch ID / Passcode)
6. Payment processes
7. Success screen shows confirmation

### Security Features
- Uses Apple's secure payment token system
- No card details ever touch your servers
- Payment token would be sent to your backend for processing
- Currently simulates successful payment (backend integration needed)

### UI Features
- Maintains terminal aesthetic throughout
- Clean breakdown of costs
- Error handling for common issues:
  - Apple Pay not available
  - No cards set up
  - Invalid amounts
  - Missing project description
- Smooth animations and transitions
- Success screen with confirmation

## Backend Integration (To Be Implemented)

Currently, the payment simulates success. To fully implement:

1. **Set up a payment processor:**
   - Stripe (recommended)
   - Square
   - Braintree
   - Adyen

2. **Create backend endpoints:**
   ```
   POST /api/payments/process
   - Receives: payment token, amount, freelancer ID, client ID
   - Returns: payment confirmation
   ```

3. **Update PaymentManager.swift:**
   In the `didAuthorizePayment` delegate method, replace the simulation with:
   ```swift
   // Send to your backend
   let paymentData = [
       "token": payment.token.paymentData.base64EncodedString(),
       "amount": selectedAmount,
       "freelancerId": freelancer.id.uuidString
   ]
   
   // Make API call to your backend
   // Your backend processes with payment processor
   // Return success/failure
   ```

4. **Backend processes:**
   - Validates payment token with payment processor
   - Deducts platform fee (5%)
   - Transfers remaining amount to freelancer
   - Creates transaction record
   - Sends confirmation emails
   - Returns success to app

## Removed Features

### Emoji Avatars ❌
All emoji avatars have been replaced with clean, terminal-style initials:
- FreelancerProfile model no longer has `avatarEmoji` property
- New `AvatarView` component shows initials in bordered box
- Maintains monospace aesthetic
- Uses accent color for borders and text

### Updated Files:
- `ModelsFreelancerProfile.swift` - Removed avatarEmoji field
- `MockData.swift` - Removed all emoji references
- `ComponentsAvatarView.swift` - New initial-based avatar component
- `ViewsFreelancerDetailView.swift` - Uses AvatarView
- `ViewsExploreView.swift` - Uses AvatarView in cards
- `ViewsGigsView.swift` - Shows "by @handle" instead of emoji
- `ViewsDashboardView.swift` - Uses AvatarView
- `ViewsProfileView.swift` - Uses SF Symbol icon instead of emoji

## Platform Fees

Current fee structure:
- **5% platform fee** on all transactions
- Shown transparently in breakdown
- Can be adjusted in `PaymentManager.createPaymentRequest()`

To change the fee:
```swift
let platformFee = PKPaymentSummaryItem(
    label: "Solomine Platform Fee",
    amount: NSDecimalNumber(value: amount * 0.05), // Change 0.05 to desired percentage
    type: .final
)
```

## Testing Checklist

- [ ] Merchant ID configured in Apple Developer account
- [ ] Apple Pay capability added to Xcode project
- [ ] Merchant ID updated in PaymentManager.swift
- [ ] Test card added to simulator/device
- [ ] Can open hire sheet from freelancer profile
- [ ] Quick amount buttons work
- [ ] Custom amount input works
- [ ] Project description required validation works
- [ ] Apple Pay sheet appears
- [ ] Payment success screen displays
- [ ] All emoji references removed from app
- [ ] Avatar initials display correctly

## Production Deployment Requirements

Before going live:
1. ✅ Merchant ID properly configured
2. ❌ Backend payment processing implemented
3. ❌ SSL certificate on backend
4. ❌ Error handling for real failures
5. ❌ Transaction logging/database
6. ❌ Email confirmations
7. ❌ Refund handling
8. ❌ Dispute resolution process
9. ❌ Escrow system (optional but recommended)
10. ❌ Tax/legal compliance

## Notes

- Apple Pay is only available on real devices or simulators running iOS 12.0+
- Test mode won't charge real cards, but will validate the flow
- Payment tokens expire after a short time (must be processed quickly)
- Always test on real device before production
- Consider adding recurring payment options for retainer-based work

---

**The payment system is now integrated and ready for backend connection!** 🚀
