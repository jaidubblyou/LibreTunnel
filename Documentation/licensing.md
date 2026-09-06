# Dependency and License Inventory

Kept up to date as dependencies are added. Per project policy, every new
dependency is evaluated against GPL-3.0-or-later compatibility, Apple
Silicon support, maintenance activity, and whether it could reasonably be
replaced later, before being adopted — see `Documentation/adr/0001` and
the "Dependency management" section of the project's contributor
guidelines.

## Third-party Swift package dependencies

None as of Phase 1. `Package.swift` declares no external packages.

## System frameworks (not redistributed, not a licensing concern)

| Framework | Used for |
|---|---|
| SwiftUI | Application UI |
| AppKit | macOS integration (indirectly, via SwiftUI) |
| Foundation | Core types, bundle/Info.plist access |

These ship with macOS/Xcode and are used under Apple's SDK terms; they
are linked at the user's/developer's own toolchain, never redistributed
by us.

## External runtime (not linked — see ADR-0002)

| Component | License | Relationship |
|---|---|---|
| OpenFOAM (OpenCFD distribution, openfoam.com) | GPL-3.0 | Invoked as an external subprocess only, never linked. Provisioned via Homebrew, driven by `OpenFOAMRuntime` (Phase 5). |

**Trademark note:** OPENFOAM® and OpenCFD® are registered trademarks of
OpenCFD Limited. LibreTunnel is not affiliated with, endorsed by, or
sponsored by OpenCFD Limited or the OpenFOAM Foundation. This notice must
appear in `README.md` and any release/marketing material that mentions
OpenFOAM by name.

## Techniques credited, not code copied

The approach of running OpenFOAM natively on macOS via a case-sensitive
mounted disk image (working around macOS's default case-insensitive
filesystem) was proven by the `gerlero/openfoam-app` project (GPL-3.0).
LibreTunnel's own `OpenFOAMRuntime` (Phase 5) will credit this project in
its documentation and source comments regardless of how much of the
technique, versus code, ends up reused directly.

## Project license

LibreTunnel itself: GPL-3.0-or-later. See `LICENSE` and
`Documentation/adr/0001-project-license.md`.
