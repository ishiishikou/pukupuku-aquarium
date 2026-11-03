# G1 real iPhone delivery gate — evidence and first authorized action

> 2026-11-03 update: User confirmed **no Mac** and prior self-built iPhone TestFlight installation. GitHub connector verified the existing Pribye manual TestFlight workflow, which the user identified as their previous working route. The Windows-only GitHub Actions path (Route B) is now the selected route. See [the corrected Pribye reuse guide](testflight-pribye-reuse.md) and the new manual deployment workflow under PR #9. Route A below is retained as an alternative, not a task for this user. No signing assets or TestFlight upload have been verified for pukupuku-aquarium.

Date: 2026-11-02 · owner: Issue #4 / release summary: Issue #7 · source: Draft PR #9.

**Current evidence**
- GitHub Actions macOS job 41457190444: XcodeGen created an Xcode project, unsigned iOS Simulator build **succeeded** and 3 XCTest tests **passed**.
- Native source implements a one-puzzle touch/haptics/audio vertical slice; there is **no signed IPA, TestFlight build or observed physical Taptic Engine behavior**.
- User reports Apple Developer Program enrollment completed. Do **not** ask for another subscription/payment.
- The checked-in bundle ID is intentionally a placeholder (jp.example.pukupuku-aquarium), and team ID is unspecified.

## Choose first physical-device route

### Route A: authorized Mac and Xcode (least provisioning complexity)

1. Obtain access to a Mac with a supported macOS/Xcode and sign in using an **authorized Apple developer account in Xcode**. The user confirmed no Mac is available; this route does not currently apply.
2. On the Mac, check out the branch codex/ios-vertical-slice-20261102 from this public repository. Install XcodeGen (via Homebrew if available).
3. Inside ios/, run xcodegen generate; open PukupukuAquarium.xcodeproj.
4. Under target Signing & Capabilities, choose the existing Apple Developer team, replace the placeholder bundle ID with an account-controlled unique identifier, and enable Automatically manage signing.
5. Pair/trust the user's iPhone, select it as a run destination, allow Developer Mode if Xcode/device requests it, then run the Debug app.
6. Observe actual stroke input, rapid and slow path, repeated crossings, Undo, sound/mute, bubble movement, haptic Off/Weak/Normal and 10-minute fatigue. Record device/OS and observations in Issue #4.

**Human-only boundary:** access to the Apple account, team/identifier selection, iPhone pairing/trust and felt tactile comfort. AI may prepare project/code/tests; it cannot legitimately impersonate Apple account ownership or physically sense the Taptic Engine.

### Route B: Windows-only through macOS CI and TestFlight

This is the fallback if no Mac is accessible. The current Actions workflow only builds **unsigned Simulator** binaries; it cannot install the app on a physical iPhone.

Required one-time **authorized account operations**:
- Select a unique bundle ID owned by the existing developer team; create/confirm the matching App Store Connect app record (and app name) before upload.
- Supply the Apple team identity and either a supported automated signing setup or an Apple Distribution certificate/private key and a matching App Store provisioning profile.
- For App Store Connect uploads, authorize an API key with appropriate role/issuer or use an authorized Xcode/cloud workflow. Give credentials to protected GitHub Actions secrets/environment **directly**; never paste them into a chat, issue, commit, pull request or public file.
- Limit deployment workflow access to protected manual/tagged releases, not arbitrary public PRs. Do not expose signing credentials to untrusted fork runs.

Then AI can configure a release-only GitHub Actions macOS archive/export/upload job for the chosen credential method, inspect CI logs, correct packaging errors and help invite internal TestFlight testers. **No secrets or active signing automation have been configured yet** because the account-specific signing method is unknown and authorization has not been granted.

### Route C: Xcode Cloud (not the current default)

Apple's Xcode Cloud initial onboarding requires Xcode, an authorized Apple developer account and a project/workspace kept in source control. Apple's setup guidance warns that a dynamically generated Xcode project/workspace can prevent initial configuration or later builds. Our project is generated from XcodeGen on CI and is not committed as .xcodeproj, so Route C needs additional preparation and initial Xcode authorization. It is not a confirmed Windows-only shortcut.

Apple references:
- https://developer.apple.com/documentation/xcode/setting-up-your-project-to-use-xcode-cloud
- https://developer.apple.com/documentation/xcode/connecting-xcode-cloud-to-github
- https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases
- https://developer.apple.com/xcode/system-requirements

## G1 acceptance checklist (cannot be checked from simulator)

| Real iPhone check | Current status |
| --- | --- |
| Install an authorized, signed build | Not established |
| Drag-water and drag-dry affect every crossed cell | Source implemented; unverified on device |
| No duplicate touches on revisits / no skips on fast diagonal | Unit/logic coverage partial; hardware unverified |
| Stroke Undo and restart are intuitive | Unit coverage partial; hardware unverified |
| Same accepted input initiates bubble, short sound and haptic | Source implemented; synchrony not measured |
| Off / weak / normal, silent mode, interruption and 10-minute comfort | Not observed |
| Record user perception independently of puzzle solving | Not collected |

**Selected route:** Route B, reuse the existing Pribye-style macOS GitHub Actions pipeline. The next human action is app-specific Bundle ID / App Store Connect record and protected GitHub environment signing access, not procuring a Mac. See testflight-pribye-reuse.md. Device installation has not yet occurred.

A successful TestFlight build will still be a prototype acceptance milestone, **not** App Store public release.
