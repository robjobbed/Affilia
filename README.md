# Affilia

Affiliate network marketplace platform (AWIN/Impact/CJ-style concept) with:
- iOS app (SwiftUI) for affiliates and companies
- Node backend API scaffolding for campaign contracts
- Web MVP prototype for browser-based flows

## Repository Layout

- `Affilia/` iOS app source (rebranded in-app to Affilia)
- `Affilia.xcodeproj` Xcode project
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
1. Open `Affilia.xcodeproj` in Xcode.
2. Build/run the `Affilia` scheme.

### Web MVP
1. Open `web/index.html` in your browser.
2. Use **Affiliate View** to browse contracts.
3. Use **Company View** to publish a contract.

## BMAD Method Integration

BMAD is now installed in this project.

### Installed Artifacts
- `_bmad/` core BMAD configuration, modules, workflows, agents, and tasks
- `.claude/commands/` generated command prompts for Claude Code

### Suggested Workflow for This Project
1. `/bmad-help` to choose the right flow for your scope.
2. `/bmad-bmm-create-product-brief`
3. `/bmad-bmm-create-prd`
4. `/bmad-bmm-create-architecture`
5. `/bmad-bmm-create-epics-and-stories`
6. Repeat per story:
   - `/bmad-bmm-create-story`
   - `/bmad-bmm-dev-story`
   - `/bmad-bmm-code-review`

### Notes
- Installation command used:
  - `npx bmad-method install --directory . --modules bmm --tools claude-code --yes`
- If you want BMAD for other IDEs/tools too, rerun install with additional `--tools` values.
