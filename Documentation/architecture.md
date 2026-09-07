# LibreTunnel Architecture

This document is the living summary of the project's architecture. Major
decisions behind it are recorded individually in `Documentation/adr/`;
this file describes how they fit together.

## Layering

```
SwiftUI Views  ──►  ViewModels (Observation framework)
                         │
                         ▼
        Application/Domain layer (pure Swift, no UI, no OpenFOAM):
        GeometryKit · DomainKit (tunnel/mesh sizing) · CaseKit (case-file
        generation) · ProjectKit (save/load) · ResultsKit (parsing)
                         │
                         ▼
        CFDBackend protocol   ◄── the only seam that knows OpenFOAM exists
                         │
                         ▼
        OpenFOAMRuntime (detection/provisioning) + SolverBridge
        (subprocess invocation, log streaming, cancellation — built on
         the shared ProcessSupervisor, see ADR-0003)
                         │
                         ▼
        Filesystem-based OpenFOAM case directory
        (fully inspectable by the user — see "Transparency" below)
```

`RenderKit` (Metal) sits alongside this stack, consuming `ResultsKit`
output and validated geometry directly. It never talks to OpenFOAM.

## The one hard rule

**OpenFOAM is invoked only as an external subprocess.** No LibreTunnel
code links against `libOpenFOAM`, `libfiniteVolume`, or any OpenFOAM
library. See ADR-0002. This is a standing constraint enforced by module
boundary and code review, not a one-time choice.

## Module map

| Module | Responsibility | Status |
|---|---|---|
| `LibreTunnel` (app) | SwiftUI shell, navigation, view models | Phase 1 shell in place |
| `AppCore` | Shared models with no UI/OpenFOAM dependency (`AppInfo`, later `ProcessSupervisor`) | `AppInfo` implemented |
| `GeometryKit` | STL/OBJ import, validation, repair | STL import implemented and tested (binary + ASCII, vertex dedup). OBJ import and validation/repair not yet started (Phase 2, remaining slices) |
| `DomainKit` | Wind-tunnel domain sizing, blockage-ratio logic | Not started (Phase 4) |
| `CaseKit` | OpenFOAM case-dictionary generation | Not started (Phase 6–7) |
| `OpenFOAMRuntime` | Detection/provisioning of the OpenFOAM runtime | Not started (Phase 5) |
| `SolverBridge` | Subprocess management for mesh/solve, built on `ProcessSupervisor` | Not started (Phase 5–7) |
| `ResultsKit` | Result and force-coefficient parsing | Not started (Phase 8) |
| `RenderKit` | Metal viewport, field colourisation, streamlines | Not started (Phase 3, 8) |
| `ProjectKit` | Project save/load, reproducibility metadata | Not started (Phase 14) |

Every module above is (or will be) an independent SwiftPM library target,
unit-testable without the UI or a live OpenFOAM install, except
`SolverBridge` and `OpenFOAMRuntime`, which additionally get integration
tests against a real OpenFOAM install.

## Transparency and reproducibility

Generated OpenFOAM cases, mesh settings, solver settings, boundary
conditions, logs, and convergence history must always be inspectable by
the user in a real, on-disk case directory — never hidden behind an
opaque intermediate format. Saved projects embed the application version
(`AppInfo`), OpenFOAM version, and all settings needed to understand how a
simulation was configured, per the project's reproducibility requirement.

## Platform

- Apple Silicon only (arm64), macOS 14 Sonoma minimum.
- Swift Package Manager only — no `.xcodeproj`, no CocoaPods/Carthage.
- Rendering via raw Metal/MetalKit, not SceneKit/RealityKit, because
  scientific visualisation (per-vertex scalar fields, custom colour maps,
  streamline integration, cutting planes) needs shader-level control
  those frameworks aren't built for. Open to revisiting if this proves
  wrong in practice — flagged here rather than buried in code.

## Benchmark case

OpenFOAM's own `motorBike` tutorial (incompressible external aerodynamics,
`simpleFoam` + `snappyHexMesh`, ships with OpenCFD, includes
`forceCoeffs` function objects) is the project's canonical reference case
from Phase 6 onward — used to validate the automated mesh/case-generation
pipeline against known-good, published behaviour rather than an
unvalidated in-house test geometry.

## Roadmap

See `PROJECT_STATE.md` for current phase/checkpoint status. Phase and
checkpoint definitions are as agreed in Phase 0 architecture discussion
(recorded in the project's development journal).
