# G0: Technical decision and build-route evidence (2026-11-02)

Context: Issue #7 defines App Store publication as the final goal. Issue #4 requires iPhone **drag-to-mark multiple cells, aligned sound/bubbles/haptic events**, verified on hardware. The user has already enrolled in the Apple Developer Program (self-reported). Do not ask them to enroll again.

## Alternatives
| Route | Advantages | Costs / risks | Initial decision |
| --- | --- | --- | --- |
| SwiftUI + Core Haptics + AVFoundation | Native gesture, Taptic Engine control, small offline game, no JS bridge timing | Xcode/macOS CI and Apple signing are unavoidable; physical-device testing still needed | **Selected as first vertical slice** |
| React Native / Expo + native haptic module | Shared UI and Android reach; JavaScript skills reusable | Native dependency and bridge scheduling, custom Core Haptics module, Xcode/signing still needed | Revisit only if native slice is inadequate |
| Web/PWA | Fast browser logic evaluation and GitHub Pages preview | Safari web vibration does not provide comparable Taptic Engine feedback; cannot prove native requirement | Keep for Issue #3 deduction evaluation only |

This is **a reversible implementation choice**, not a claim that native touch feedback has passed testing.

## Evidence and boundaries
- Apple documents Core Haptics transient haptic events and system/device constraints: https://developer.apple.com/documentation/corehaptics
- Apple maintains the current Xcode–macOS–SDK compatibility matrix: https://developer.apple.com/xcode/system-requirements
- App Store Connect requires a supported Xcode/SDK for upload; verify again when submitting: https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/
- Repository includes ios/project.yml for XcodeGen and a GitHub-hosted macOS **unsigned simulator build** workflow. This does not prove that a signing team, bundle ID, certificate, App Store Connect role, or iPhone delivery is configured.
- Avoid embedding signing secrets in the public repo. For real devices, use a separately authorized Apple account / secure CI signing flow, or Xcode on a Mac.
- Because the accessible tool environment is Linux and the user is Windows-first, native compilation is delegated to the macOS CI runner. **Do not report a build as successful until its run is checked.**

## No premature gate closure
- **G0 candidate architecture documented**, source created; CI build and signed distribution require evidence.
- **G1 remains open** until physical iPhone gestures, short/long swipe, replay prevention, audio/haptic synchronization and subjective comfort are verified.
- **G2 browser puzzle logic stays separate** from input-comfort acceptance; puzzles must each have uniqueness and no-guess reasoning evidence.
- **G3–G5** remain open; TestFlight is not public release.
