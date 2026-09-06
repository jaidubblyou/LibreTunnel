# LibreTunnel

An open-source, native macOS virtual wind tunnel and CFD application,
built on [OpenFOAM](https://www.openfoam.com), for Apple Silicon.

LibreTunnel aims to take a 3D model from **Import → Inspect → Tunnel →
Simulate → Analyse** without requiring the user to understand Linux,
the command line, CFD configuration files, or OpenFOAM internals —
while keeping every generated case, mesh setting, and log file fully
inspectable for anyone who wants to look.

> **Project status: early development (Phase 1 of 12).** The application
> currently launches and shows the primary workflow navigation as
> placeholders. No geometry import, meshing, simulation, or visualisation
> exists yet. See `PROJECT_STATE.md` for the current, detailed status and
> `Documentation/architecture.md` for the full roadmap.

## Platform requirements

- Apple Silicon Mac (M1 or later) — Intel is not supported.
- macOS 14 Sonoma or later.

## Installing

*(Release builds are not yet available — Phase 1 is a development
scaffold. This section is written ahead of time so it's accurate the
moment a release exists.)*

LibreTunnel releases are **ad-hoc signed, not notarized by Apple** — no
paid Apple Developer account is used for this project (see
`Documentation/adr/0004-code-signing-without-developer-id.md`). On first
launch, macOS will show a warning that it could not verify the app.
This is expected. To open it:

1. Download and open the `.dmg`, drag LibreTunnel to Applications.
2. In Finder, **right-click LibreTunnel.app → Open** (only needed once).
3. Click **Open** on the confirmation dialog.

No Terminal or command line is required for this step.

## Building from source

See `Documentation/developer-setup.md`.

```bash
git clone https://github.com/<org>/LibreTunnel.git
cd LibreTunnel
swift build
swift test
swift run
```

## Documentation

- [`Documentation/architecture.md`](Documentation/architecture.md) — how the project is structured, and why.
- [`Documentation/adr/`](Documentation/adr/) — architecture decision records.
- [`Documentation/developer-setup.md`](Documentation/developer-setup.md) — build/run/test instructions.
- [`Documentation/testing.md`](Documentation/testing.md) — what's tested and how.
- [`Documentation/licensing.md`](Documentation/licensing.md) — dependency and license inventory.
- [`PROJECT_STATE.md`](PROJECT_STATE.md) — the living, detailed project state and development journal.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md). Contributions are welcome at any
skill intersection this project touches (SwiftUI, Metal, geometry
processing, OpenFOAM/CFD) — the module structure is deliberately split so
you don't need all of them at once.

## License

LibreTunnel is licensed under the GNU General Public License v3.0 or
later — see [`LICENSE`](LICENSE) and
[`Documentation/adr/0001-project-license.md`](Documentation/adr/0001-project-license.md).

## Trademark notice

OPENFOAM® and OpenCFD® are registered trademarks of OpenCFD Limited.
LibreTunnel is an independent, community-developed project and is **not
affiliated with, endorsed by, or sponsored by** OpenCFD Limited or the
OpenFOAM Foundation.
