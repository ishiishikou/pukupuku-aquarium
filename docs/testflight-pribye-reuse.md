# Windows-only TestFlight delivery: reuse Pribye, not ShareCheck

Updated 2026-11-03 · Source: Issue #4, master Issue #7, Draft PR #9.

## Correction of prior assumption

The user confirmed that a **self-built app was installed via TestFlight for Pribye**, whereas ShareCheck was abandoned before reaching that step. The previous ShareCheck-based plan is superseded.

GitHub connector verified the source workflow at:
- ishiishikou/pribye/.github/workflows/testflight.yml
- Pribye project.yml (XcodeGen)

Pribye uses GitHub Actions macOS, XcodeGen, a signing .p12, App Store provisioning profile, an App Store Connect **raw .p8 key**, archive/export and altool upload. Pribye has additional LiteRT/bazel preparation that **is not needed** for Pukupuku and has been omitted.

We did not inspect any secret values. We also did not independently confirm the historical successful Pribye GitHub run; the historical TestFlight installation is the user's report. **Secrets stored in Pribye are not automatically available in Pukupuku**.

## Pukupuku workflow now prepared

.github/workflows/testflight.yml in PR #9 mirrors the **Pribye credential encoding and naming**, with these intentional differences:

- PukupukuAquarium scheme and ios/PukupukuAquarium.xcodeproj
- manual workflow_dispatch, trusted main branch only, GitHub Environment testflight
- Xcode 26+ availability check, XcodeGen in ios/; no LiteRT/bazel
- unique app-specific bundle identifier and existing developer team's ID supplied via protected environment secrets
- separate signing profile for this app; optional reuse of still-valid distribution identity/API credentials
- generated prototype app icon for validation (not final branding), to be replaced before App Store submission
- unsigned iPhone Release archive tested separately in CI before attempting signed upload

**This workflow has not been executed with signing material and no TestFlight build has been uploaded.**

## GitHub Environment: required secret names only

Go to repository Settings > Environments > testflight. Restrict the environment to a trusted deployment branch and explicitly authorize release changes. Configure the following as protected secrets, **without pasting values into ChatGPT, Issues, code, or PR descriptions**:

| Secret | Meaning |
| --- | --- |
| APP_BUNDLE_ID | New Pukupuku bundle ID registered for this app (not Pribye's bundle ID) |
| APPLE_TEAM_ID | Existing Apple Developer team ID (can be the same team as Pribye) |
| APP_STORE_CONNECT_API_KEY_ID | Authorized App Store Connect key identifier |
| APP_STORE_CONNECT_ISSUER_ID | Matching issuer identifier |
| APP_STORE_CONNECT_API_KEY_P8 | **Raw** private key text, just as in the Pribye workflow |
| BUILD_CERTIFICATE_BASE64 | Base64 of valid Apple Distribution .p12 identity |
| P12_PASSWORD | Password for that .p12 |
| BUILD_PROVISION_PROFILE_BASE64 | Base64 of Pukupuku-specific App Store provisioning profile |
| KEYCHAIN_PASSWORD | Temporary keychain password used during runner setup |

Different encoding matters: the earlier ShareCheck pipeline used base64 for its API private key, but Pribye uses the **raw p8** string. Do not copy the old secret format without checking. The Pukupuku provisioning profile must match its newly registered bundle ID and team. Existing Pribye certificates and API keys **may** be reusable under the same account if current and sufficiently authorized; do not assume they work without validation.

## New app identity and account-side operations

A new explicit App ID / Bundle ID and App Store Connect app record are needed for Pukupuku. These operations belong to the Apple account owner; the app cannot take Pribye's bundle ID. The upload workflow is intentionally not invoked until these exist.

Because the repo is public, never put credentials in PR-triggered workflows and never upload signing assets as downloadable artifacts. The TestFlight manual workflow runs on the trusted main ref only; its YAML must be merged by an explicitly authorized user before the Actions UI can execute it. A passing unsigned CI build is not evidence of successful signed upload or physical haptics.

## Next actions

1. AI: finish validation of the unsigned Release iPhone archive, TestFlight YAML structure, and prototype AppIcon packaging in GitHub Actions.
2. Account owner: register a Pukupuku-specific bundle ID and App Store Connect app (using existing Apple Developer membership), then configure the new protected GitHub environment secrets above, or explicitly authorize a capable connector to do the supported operations.
3. AI: after authorization, inspect the manual workflow run, fix packaging/signing/upload errors without exposing credentials.
4. Owner: install the processed TestFlight build on iPhone; assess bubble, short sound, haptic (off/weak/normal), fast/swipe/revisit/Undo and comfort. Log subjective game enjoyment separately from technical correctness.

No local Mac is required by this route; Apple's account operations and actual physical feedback cannot be simulated by CI.

Apple reference: https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/
