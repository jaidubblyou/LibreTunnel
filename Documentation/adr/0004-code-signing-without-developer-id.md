# ADR-0004: Code Signing and Distribution Without a Paid Apple Developer ID

**Status:** Accepted
**Date:** 2026-09-06

## Context

Apple notarization — the mechanism that lets a downloaded macOS app launch
with no Gatekeeper warning at all — requires a Developer ID Application
certificate, which requires paid enrollment in the Apple Developer Program
($99/year). There is no free tier for this. For a community project, that
cost requires a responsible party to pay it and hold the account, which is
a governance question this project isn't ready to answer yet.

## Decision

LibreTunnel releases are **ad-hoc signed** (`codesign --sign -`), not
notarized, and no Apple Developer Program enrollment is required. This
costs nothing and needs no Apple account beyond what any Mac already has.

Consequence accepted deliberately: on first launch, Gatekeeper shows an
"Apple could not verify this app is free of malware" warning, and the user
must right-click the app and choose Open once. This is a one-time GUI
action — no Terminal or command line involved — but it is a "trust me"
dialog that will look alarming to a non-technical user, and we are not
pretending otherwise.

Mitigations, since accessibility matters to this project:
- The release `.dmg` includes a background image showing both the
  drag-to-Applications step and the right-click-to-open step.
- The same instructions appear in the GitHub Release notes and in
  `README.md`, "Installing."
- This exact flow is a required pass/fail check at Checkpoint 16
  (fresh-machine installation), not an assumed-fine step.

This same technique is already used, at the time of writing, by
`gerlero/openfoam-app` for the OpenFOAM runtime itself — so users will see
at most one such prompt, for LibreTunnel.app, because our own runtime
provisioning (ADR-0002) installs OpenFOAM with `--no-quarantine` and
therefore does not trigger a second one.

## Alternatives considered

- **Full notarization via a paid Developer ID** — best end-user
  experience, zero Gatekeeper friction, but requires ongoing funding and a
  named account holder. Not ruled out permanently: revisit if the project
  secures sponsorship (e.g. GitHub Sponsors / Open Collective) and
  Gatekeeper friction proves to be a real adoption blocker once there are
  users to observe.
- **Fully unsigned (no `codesign` at all)** — costs nothing extra over
  ad-hoc signing but gives up a valid, stable code signature for no
  benefit. Rejected in favour of always ad-hoc signing at minimum.

## Consequences

- No Mac App Store distribution is possible without notarization anyway
  (the Store requires full paid enrollment), which is moot since
  distribution is via GitHub Releases, not the App Store.
- Some managed/corporate Macs with Gatekeeper override disabled by MDM
  policy will not be able to run LibreTunnel at all. Accepted as an edge
  case for this project's audience.
- This decision is fully reversible later: adding notarization is a CI/
  release-pipeline change only (one additional `notarytool` step), with no
  required changes to application code or architecture.
