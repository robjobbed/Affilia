# Affilia

Affiliate network marketplace platform (AWIN/Impact/CJ-style concept) with:
- iOS app (SwiftUI) for affiliates and companies
- Node backend API scaffolding for campaign contracts
- Web MVP prototype for browser-based flows

## Repository Layout

- `Solomine/` iOS app source (rebranded in-app to Affilia)
- `Solomine.xcodeproj` Xcode project
- `web/` lightweight web MVP (`index.html`, `app.js`, `styles.css`)

## Core Product Direction

- Affiliates can join the network and apply to campaign contracts
- Companies can publish campaign contracts with commission terms
- Contract model supports:
  - Commission type (`CPA`, `REV SHARE`, `HYBRID`)
  - Commission value
  - Cookie window
  - Target region

## Quick Start

### iOS
1. Open `Solomine.xcodeproj` in Xcode.
2. Build/run the `Solomine` scheme.

### Web MVP
1. Open `web/index.html` in your browser.
2. Use **Affiliate View** to browse contracts.
3. Use **Company View** to publish a contract.
