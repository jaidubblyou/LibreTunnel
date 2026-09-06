# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project intends to follow [Semantic Versioning](https://semver.org/)
once versioned releases begin.

## [Unreleased]

### Added

- Phase 1 native application shell: SwiftUI window with sidebar navigation
  across the five workflow stages (Import, Inspect, Tunnel, Simulate,
  Analyse), each currently a clearly-labeled placeholder.
- `AppCore` module with `AppInfo` (version/build metadata), including
  unit tests.
- Project scaffold: license (GPL-3.0-or-later), architecture decision
  records (ADR-0001 through 0004), contributor documentation, issue/PR
  templates, and CI (build + test on Apple Silicon GitHub-hosted
  runners).
- Release packaging script (`Scripts/build-app-bundle.sh`) producing an
  ad-hoc signed `.app` bundle, per ADR-0004.

### Known limitations

- No geometry import, meshing, OpenFOAM integration, or visualisation
  yet — this is Phase 1 of 12. See `PROJECT_STATE.md` for full status.
- The Phase 1 code was authored without access to a macOS/Xcode
  toolchain and has not yet been compiled or run on real hardware; it is
  IMPLEMENTED but NOT YET TESTED until CI or a human confirms it (see
  `PROJECT_STATE.md`, Session Checkpoint).
