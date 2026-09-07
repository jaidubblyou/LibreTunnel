# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project intends to follow [Semantic Versioning](https://semver.org/)
once versioned releases begin.

## [Unreleased]

### Added

- **Phase 2 (slice 1): STL geometry import.** New `GeometryKit` module:
  `TriangleMesh` (shared indexed-mesh model, see ADR-0005),
  `STLImporter` supporting both binary and ASCII STL with robust
  binary/ASCII disambiguation, vertex deduplication, and descriptive
  errors for malformed files. The Import workflow stage now has real
  functionality — a file picker, parse-result summary (vertex/triangle
  counts, bounding box), and understandable error display — replacing
  its placeholder. OBJ import and geometry validation/repair are the
  next slices of this phase, not yet started.
- Phase 1 native application shell: SwiftUI window with sidebar navigation
  across the five workflow stages (Import, Inspect, Tunnel, Simulate,
  Analyse). Import now has real content; the other four remain
  clearly-labeled placeholders.
- `AppCore` module with `AppInfo` (version/build metadata), including
  unit tests.
- Project scaffold: license (GPL-3.0-or-later), architecture decision
  records (ADR-0001 through 0005), contributor documentation, issue/PR
  templates, and CI (build + test on Apple Silicon GitHub-hosted
  runners).
- Release packaging script (`Scripts/build-app-bundle.sh`) producing an
  ad-hoc signed `.app` bundle, per ADR-0004.

### Known limitations

- No OBJ import, geometry validation/repair, meshing, OpenFOAM
  integration, or visualisation yet — this is Phase 2 of 12, first
  slice. See `PROJECT_STATE.md` for full status.
- Phase 1 has been fully verified on real Apple Silicon hardware (build,
  tests, and app launch all confirmed). Phase 2 slice 1's `GeometryKit`
  tests have not yet been run on real hardware — see `PROJECT_STATE.md`.
