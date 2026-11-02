# iPhone native vertical slice — Issue #4

This is a **source-only, unsigned, single-puzzle vertical slice**, not a production app or verified haptic experience. The official browser prototype in PR #6 independently evaluates logical deduction. The native app tests gesture mechanics and sensory feedback on an iPhone.

## What is implemented
- 5×5 representative puzzle (same constraints as PR #6), **no stored solution used for victory**.
- Water/dry mode, drag over many cells, fast-drag point interpolation, same-stroke revisits ignored, one-step **stroke-level** Undo, persistence in UserDefaults.
- Bubble visual and short synthesized sound + CHHapticEngine transient on accepted cell input. Separate switches for movement, audio and haptics. No feedback difference based on correctness.
- Local data only; no account or network access.

## Build without a local Mac
The GitHub Actions workflow in .github/workflows/ios-simulator-build.yml can build without a signing certificate on a GitHub-hosted macOS runner. A successful simulator build **does not install the app on your iPhone**, establish Apple code signing, or verify haptic/audio behavior.

## Actual installation / real-device acceptance
1. A macOS/Xcode build environment or a properly configured cloud signing/distribution service is necessary.
2. Generate the project with xcodegen generate inside ios/ and open PukupukuAquarium.xcodeproj in Xcode.
3. Select the existing Apple Developer team and **replace the placeholder** jp.example.pukupuku-aquarium with a bundle identifier controlled by the account.
4. Build to a device or archive/upload a signed build through the Apple distribution pipeline; this step requires permissions/secrets not embedded in this public repository.
5. Test drags in every direction, repeated visits, rapid swipes, interruptions, mute, settings, 10-minute fatigue, and compare haptics off/low/normal. The app now exposes weak/normal prototype settings. Final intensity/timing tuning is *pending real-device testing*.

Nothing in this repository claims developer enrollment is missing: the user reported that enrollment is complete. No secret, private key, provisioning profile or App Store credential should be committed.

## Known limitations and next work
- Cloud-hosted unsigned simulator builds cannot confirm Core Haptics on physical iPhone hardware.
- Proof of device build, signing route, and user perception is pending.
- The puzzle is intentionally one level; no product release flow, 100-question bank, optional sixth question, iOS tutorial, or App Store submission is present.
- Continue Issue #4 until gesture + feedback are accepted **on real hardware**. Issue #7 tracks release readiness.
