# Developer Setup

## Prerequisites

- An Apple Silicon Mac (M1 or later). Intel is not supported — see
  `Documentation/adr/0002-openfoam-runtime-strategy.md`.
- macOS 14 (Sonoma) or later.
- Xcode 15 or later (for the Swift 5.10 toolchain and to run/debug the app
  with SwiftUI previews).

You do **not** need Homebrew or OpenFOAM installed to build and run the
Phase 1 application shell — those are only required once `OpenFOAMRuntime`
lands (Phase 5).

## Clone and build

```bash
git clone https://github.com/<org>/LibreTunnel.git
cd LibreTunnel
swift build
```

## Run

```bash
swift run
```

This launches the app shell directly. You can also open `Package.swift`
in Xcode (File → Open, select `Package.swift`) and run the `LibreTunnel`
scheme to get SwiftUI previews and the debugger.

## Test

```bash
swift test
```

See `Documentation/testing.md` for what's covered and how test
responsibility is split across modules.

## Building a distributable app bundle

```bash
./Scripts/build-app-bundle.sh
```

Produces `dist/LibreTunnel.app`, ad-hoc signed per
`Documentation/adr/0004-code-signing-without-developer-id.md`.

## A note on this repository's origin

The initial Phase 1 scaffold (this file included) was authored in a
non-macOS environment with no Swift toolchain available, and so could not
be compiled or run by its author before being committed. It should be
treated as **implemented but not yet verified** until CI (see
`.github/workflows/ci.yml`) or a human running it on real hardware
confirms it. If you're the first person to run `swift build` on this
repository, please open an issue with the result either way — a clean
pass is useful confirmation, and a failure is exactly the kind of thing
this note is meant to surface quickly rather than let sit undiscovered.
