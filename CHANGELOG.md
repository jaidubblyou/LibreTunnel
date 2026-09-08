# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project intends to follow [Semantic Versioning](https://semver.org/)
once versioned releases begin.

## [Unreleased]

### Added

- **Phase 2 (slice 2): OBJ geometry import.** New `OBJImporter` in
  `GeometryKit`: parses vertices and faces, fan-triangulates polygon
  faces, handles all standard face-vertex syntax variants and negative
  (relative) indices, and computes true geometric face normals rather
  than trusting the file's `vn` data (see ADR-0005's amendment for why).
  New `GeometryImporter` dispatches between STL and OBJ by file
  extension, so the app no longer hard-codes format selection. The
  Import stage now accepts both `.stl` and `.obj` files.
- **Phase 2 (slice 1): STL geometry import.** New `GeometryKit` module:
  `TriangleMesh` (shared indexed-mesh model, see ADR-0005),
  `STLImporter` supporting both binary and ASCII STL with robust
  binary/ASCII disambiguation, vertex deduplication, and descriptive
  errors for malformed files. The Import workflow stage now has real
  functionality — a file picker, parse-result summary (vertex/triangle
  counts, bounding box), and understandable error display — replacing
  its placeholder. Geometry validation/repair is the next (and final)
  slice of this phase, not yet started.
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

### Fixed

- `STLImporter.isLikelyBinary` no longer misclassifies short, valid
  ASCII STL files (e.g. an empty solid) as binary. Found by
  `testThrowsOnEmptyASCIIFile` failing on real hardware, root-caused,
  fixed, and re-verified — see `PROJECT_STATE.md` for the full account.
- `swift run`'s missing Dock icon (a known characteristic of unbundled
  Swift executables, not a LibreTunnel-specific defect) is now worked
  around during development via an explicit `AppDelegate` activation
  policy — irrelevant once the app is packaged as a real `.app` bundle,
  which already gets this by default.

### Known limitations

- No geometry validation/repair, meshing, OpenFOAM integration, or
  visualisation yet — this is Phase 2 of 12, second of its (currently)
  two completed slices. See `PROJECT_STATE.md` for full status.
- OBJ import fan-triangulates polygon faces, which is correct for
  convex faces but not guaranteed correct for concave ones — see
  ADR-0005's amendment.
- Import uses a file-picker button, not literal drag-and-drop onto the
  window, despite the original requirement's wording — tracked as an
  open item, not silently considered satisfied.
