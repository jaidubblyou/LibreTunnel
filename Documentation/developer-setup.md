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

**A note on the Dock icon:** running via `swift run` produces a bare
executable, not a real `.app` bundle recognized by LaunchServices. The
app's `AppDelegate` explicitly claims regular-app status on launch
(`NSApp.setActivationPolicy(.regular)`), so you should see a normal
Dock icon and Cmd+Tab presence even in this dev-run mode — but if it's
ever missing, that's a known, harmless quirk of unbundled executables,
not a sign the app failed to launch. Check Mission Control or the
desktop; the window is very likely there. It's a non-issue once the app
is packaged via `Scripts/build-app-bundle.sh` and opened normally,
since a real bundle gets `.regular` by default with no extra code
needed.

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
