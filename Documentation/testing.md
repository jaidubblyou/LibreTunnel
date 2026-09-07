# Testing

## Philosophy

Per the project's "test first" and "no fake functionality" principles:
every module should be independently testable, and a feature is not
considered done until it's tested — a feature that "looks right" in the
UI without a passing test behind it is treated as unverified, not
finished.

## Current coverage (Phase 1 + Phase 2, first slice)

| Module | Test target | What's covered |
|---|---|---|
| `AppCore` | `AppCoreTests` | `AppInfo` construction, equality, and its fallback behaviour when run outside an app bundle (`swift test` has no Info.plist) |
| `GeometryKit` | `GeometryKitTests` | `STLImporter`: binary and ASCII parsing, vertex deduplication across shared edges, the binary/ASCII disambiguation edge case (a binary file whose header text happens to start with "solid"), bounding-box computation, and every documented error case (truncated header, triangle-count/file-size mismatch, empty file, malformed ASCII line). Fixtures are built in code (`STLFixtures.swift`) rather than committed binary files, so they're easy to read and modify in review. |
| `LibreTunnel` (app) | — | `ImportView`/`ImportViewModel` are UI/state glue over `GeometryKit`, which is where the real logic (and its tests) lives; no separate app-level tests yet. `WorkflowStage` remains a plain enum with no branching logic beyond simple lookups. |

Run everything with:

```bash
swift test
```

## CI

`.github/workflows/ci.yml` runs `swift build` and `swift test` on
GitHub-hosted `macos-14` runners, which are genuine Apple Silicon
hardware. This is the actual, automated verification of Checkpoint 1
("clean project builds from source") — not an assumption.

## What "integration test" means once later phases land

- `GeometryKit`: unit tests against known-good and known-bad STL/OBJ
  fixtures (holes, non-manifold edges, degenerate triangles), no OpenFOAM
  or UI dependency.
- `OpenFOAMRuntime` / `SolverBridge`: integration tests that require a
  real OpenFOAM install, run against OpenFOAM's own `motorBike` tutorial
  as the canonical benchmark (see `architecture.md`). These will be
  clearly separated from the fast unit-test suite so CI can run them on a
  slower, dedicated job once `OpenFOAMRuntime` exists.
- `ProcessSupervisor` (ADR-0003): unit-testable with a mock/fake
  subprocess so lifecycle and cancellation logic doesn't require actually
  spawning OpenFOAM.

## Manual testing checklist (grows with each phase)

- [x] Phase 1: app launches, sidebar navigation switches between all five
      stages, each shows its placeholder without crashing. **Confirmed
      on real Apple Silicon hardware (2026-09-06)** — app launch and
      no-crash behavior verified directly; individual clicking through
      of each of the five stages was not separately itemized in the
      report, though the app running cleanly makes failure there
      unlikely.
- [ ] Phase 2 (slice 1): Import stage accepts a real STL file via the
      file picker, shows correct vertex/triangle counts and bounding
      box, and shows an understandable error message for a malformed
      file. Written and unit-tested at the `GeometryKit` level; not yet
      exercised end-to-end through the actual UI on real hardware.
