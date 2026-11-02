# Windows + GitHub Actions → TestFlight: reuse the existing ShareCheck route

Updated: 2026-11-03 · Issue #4 / master Issue #7 · Draft PR #9.

## Newly verified facts
- **No Mac is available to the user.** Do not ask them to use a local Mac/Xcode.
- The user has already installed at least one self-built iOS app using TestFlight and has Apple Developer Program membership.
- GitHub connector read the existing reusable workflow at ishiishikou/ShareCheck, path .github/workflows/testflight.yml. It is a **manual workflow_dispatch**, macOS-hosted XcodeGen archive/export/upload pipeline, protected job environment named testflight.
- The earlier workflow source contains names of credentials but **not their values**. GitHub connector did not establish whether these secrets still exist, are valid, or have been copied into pukupuku-aquarium. A successful historical TestFlight installation was reported by the user, **not independently traced to this exact workflow run**.
- In pukupuku-aquarium PR #9, unsigned simulator CI and 3 XCTest tests passed (run 41457190444). This confirms compilation, not TestFlight signing.

## Action taken
New workflow: .github/workflows/testflight.yml on PR #9.
- Copied the architecture from ShareCheck instead of inventing a new CI provider.
- Changed app/scheme/project to PukupukuAquarium and ios/PukupukuAquarium.xcodeproj.
- Uses GitHub macOS runner; checks current Xcode is version 26+; runs xcodegen in ios/.
- Manual workflow_dispatch only; with environment testflight and read-only GITHUB_TOKEN.
- Installs signing certificate and matching provisioning profile in an ephemeral runner keychain, signs archive, exports App Store Connect IPA and uploads via altool. Cleans temporary signing files.
- **Not triggered and not deployed.** The workflow file is on a Draft PR branch, not the default branch. GitHub workflow_dispatch typically requires a workflow file on the default branch before GitHub Actions UI can manually trigger it.

## Secure environment configuration: names only

In GitHub > pukupuku-aquarium > Settings > Environments > testflight,
configure protection (restrict deployments to a trusted release branch; optional required reviewers as available). Then configure these secrets **directly in GitHub UI**; do not paste their contents into ChatGPT or public GitHub PR/Issues:

| Environment secret | Can it be reused? |
| --- | --- |
| APPLE_TEAM_ID | Same existing Apple Developer team as ShareCheck |
| APP_BUNDLE_ID | **New** unique ID registered for this game, not ShareCheck's |
| IOS_DISTRIBUTION_CERTIFICATE_BASE64 | Existing Apple Distribution identity might be reusable if still valid, same team, exportable .p12 with private key |
| IOS_DISTRIBUTION_CERTIFICATE_PASSWORD | Password of that .p12 (potentially reusable only with same exported certificate) |
| IOS_PROVISIONING_PROFILE_BASE64 | **Must match new bundle ID and team**; ShareCheck's app-specific profile cannot simply be copied |
| APP_STORE_CONNECT_API_KEY_ID | Existing key might be reusable with sufficient authorization |
| APP_STORE_CONNECT_API_ISSUER_ID | Existing App Store Connect issuer for same account |
| APP_STORE_CONNECT_API_PRIVATE_KEY_BASE64 | Existing API private key might be reusable if valid and authorized; prefer protected secret storage |

A separate App Store Connect app record for the chosen bundle ID is required. Signing certificate/profile and API credentials for the old app must not be presumed valid just because the earlier deployment worked.

## First human-only step

Confirm/create an app-specific Bundle ID and App Store Connect record, then make the required credential names available to the **new repository's** protected testflight environment (or delegate GitHub/Apple actions through explicitly authorized connectors). A repo-scoped secret in ShareCheck is not automatically available in pukupuku-aquarium. Do not expose old secret values to the chat.

The manual TestFlight workflow must also reach the default branch through an explicitly approved integration process; don't merge nested Draft PRs without approval. Then trigger from GitHub Actions with controlled version/build number and check signing/export/upload logs. A successful upload still needs Apple's build processing and internal tester access before installation.

## Outstanding risk before upload
- Source currently does not include final App Store icon artwork/marketing metadata. Apple validation may reject missing icons or other metadata. Fix errors when verified rather than asserting deployment success.
- Signing artifacts and App Store Connect permissions are unverified.
- App Store Connect/TestFlight App ID, bundle ID and build number must match; protect against shipping unreviewed public PR code.
- The final user acceptance of bubbles, sound, and **physical haptics** requires installing the build on an actual iPhone.

Official reference: https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/
