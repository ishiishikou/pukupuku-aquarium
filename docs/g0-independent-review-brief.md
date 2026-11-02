# Independent G0/G1 architecture review brief — prepared, not submitted

Date: 2026-11-02 · Release readiness: Issue #7 · G1 controls: Issue #4.

**Reviewer role:** independently examine the technical direction toward App Store release, not the user's task delegation or the superficial completeness of each code change. This review brief can be handed to Astra or another independent technical reviewer when available. No review has yet been claimed.

## Product constraints

- Final goal: public iPhone App Store release, not web MVP or TestFlight alone.
- The user likes Meowdoku!'s moderate/stable difficulty, tactile tapping and approachable art. The original game is an Aquarium-style water-level logic puzzle, with differentiated bubble/touch/sea-life experience. Intellectual-property/originality and misleading store claims need review.
- Web evaluates the moment of *deductive insight*; iPhone **must** support drag marking of multiple water/dry cells and per-accepted-cell bubble, audio and haptic feedback.
- Current intended bank size is about 100 **base** puzzles, with verified transformations and replay management, not advertised as infinitely many independent problems.
- Level/daily progress should support continuing use while avoiding deceptive or excessively coercive prompts.
- Developer Program enrollment was already completed by the user; signing/distribution still needs separately verified credentials.

## Relevant artifacts

- PR #1: prototype source and reasoning review.
- PR #6: one 5×5 playable browser example.
- PR #8: public App Store roadmap and 100-base-puzzle decision.
- PR #9: native SwiftUI, drag + Core Haptics + AVFoundation, independent weak/normal/off settings. macOS hosted CI run 41457190444 successfully built an unsigned simulator target and ran 3 XCTest tests.
- PR #10: 3 tutorials + 5 main puzzles + voluntary sixth in browser, nine complete unique-water-level proofs and Chrome smoke tests; latest CI run 41457722630 successful.
- Issue #3: human inference pleasure and voluntary continuation. Issue #4: physical tactile feedback. Issue #5: stable difficulty/problem bank. Issue #7: G0–G5 completion gates.
- G0 selected first native vertical slice over React Native/native module and PWA. This is provisional until physical hardware evidence; see docs/ios-technical-decision.md and docs/device-distribution-gate.md.

## Questions for the independent reviewer

1. Is native SwiftUI + Core Haptics + AVFoundation the appropriate initial implementation for low-latency drag feedback on iPhone, given a predominantly Windows developer and GitHub-hosted macOS CI? Identify a **specific** high-risk assumption and a minimal decisive test.
2. Is the real-device installation path feasible without asking the user to purchase a second developer membership? Distinguish what can be automated from Apple account sign-in, provisioning, device pairing and TestFlight authorization.
3. Are sign-in credentials, bundle ID, CI protection and release workflows safely separated from public PRs? Recommend controls, not credentials pasted into an issue.
4. Which measured properties must be collected on the phone before the 100-base-puzzle bank or extensive UI polish? Separate proof of mathematical correctness, reasoning delight, tactile comfort and store readiness.
5. Does the plan adequately distinguish original assets from third-party games and avoid inaccurate claims about independent puzzles, daily progress or rankings?
6. What are the top three risks to G1→G5 and the cheapest next decisive experiment? Indicate any proposal that would reverse the current architecture choice.

## Expected output

An evidence table **confirmed / inferred / untested**, decision recommendation with invalidation conditions, no more than three actionable blockers ordered by urgency, and an acceptance test for each. Do not certify G1 or App Store publication from simulator/Chrome CI. Review is *pending*; this document is only an invitation-ready brief.
