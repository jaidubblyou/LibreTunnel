# PROJECT STATE

> **Purpose:** This file is the persistent source of truth for the project's current state.
>
> **IMPORTANT FOR ANY AI AGENT:** Read this file before making changes to the project. Do not assume that the conversation history contains the complete project context. The files in the repository and this document take precedence over assumptions from previous conversations.

---

## 1. PROJECT

**Project name:**
LibreTunnel

**Description:**
An open-source, native macOS virtual wind tunnel and CFD application built
on OpenFOAM. Takes a user from a 3D model (STL/OBJ) through geometry
inspection, automatic wind-tunnel/mesh generation, local OpenFOAM
simulation, and interactive results analysis, without requiring the user
to touch the command line, Linux, or OpenFOAM configuration files
directly — while keeping every generated case, mesh setting, and log
fully inspectable.

**Current objective:**
Phase 2, slice 2, is written: OBJ geometry import, dispatched alongside
STL via a new `GeometryImporter`. Not yet verified on real hardware
(see Section 16). Remaining Phase 2 slice: geometry validation/repair.

**Project status:**
`DEVELOPMENT` (Phase 1 of 12 complete and verified; Phase 2 of 12 in
progress — slice 1 [STL import] complete and verified, slice 2 [OBJ
import] written and unit-tested but not yet run on real hardware — see
`Documentation/architecture.md` for the full phase list)

**Last updated:**
2026-09-07

**Last updated by:**
AI (Claude), in direct collaboration with the project owner across a
multi-session architecture discussion and initial scaffold build.

---

## 2. CORE REQUIREMENTS

### Functional requirements

- [x] Drag-and-drop import of STL and OBJ 3D models — **both formats
      now import successfully**. Still open: import currently uses a
      file picker (`.fileImporter`), not literal drag-and-drop onto the
      window — that UX refinement remains a tracked gap, not silently
      considered done (see Section 10).
- [ ] Geometry inspection/validation in a polished 3D viewport (holes,
      non-manifold edges, inverted normals, duplicate/degenerate geometry,
      disconnected components, unrealistic scale)
- [ ] Automatic virtual wind-tunnel domain and CFD mesh generation
- [ ] User-configurable airflow conditions: speed, angle of attack, yaw
- [ ] Local OpenFOAM simulation execution (no cloud/remote dependency)
- [ ] Real-time convergence and system-resource monitoring during solving
- [ ] Interactive results visualisation: pressure, velocity, streamlines,
      drag, lift
- [ ] Several simulation-quality presets, from lightweight preview to
      higher-fidelity, with performance/memory impact visible to the user
- [ ] Inspectable OpenFOAM case, mesh settings, solver settings, boundary
      conditions, logs, and convergence history at any time
- [ ] Project save/load with enough embedded metadata (app version,
      OpenFOAM version, solver, mesh config, fluid properties, boundary
      conditions, reference values) to reproduce a simulation

### Technical requirements

- [ ] Genuinely native macOS application (SwiftUI/AppKit/Metal), not
      Electron or a cross-platform UI toolkit
- [ ] Apple Silicon only (see Section 3 decisions) — no Intel support
- [ ] Must run acceptably on an M1 Mac with 8 GB RAM; UI must stay
      responsive during import, preprocessing, meshing, solving, and
      result loading
- [ ] Modular architecture with clear separation between UI, geometry
      import/validation/preprocessing, mesh generation, OpenFOAM runtime
      management, case generation, solver execution, result parsing,
      analysis, and visualisation
- [ ] OpenFOAM invoked only as an external subprocess — never linked as a
      library (hard rule, see ADR-0002 and Section 3)
- [ ] Reproducible builds via Swift Package Manager, no `.xcodeproj`
- [ ] CI: automated build + test on genuine Apple Silicon runners

### UX / design requirements

- [ ] Clean, modern, professional macOS interface
- [ ] Primary workflow: Import → Inspect → Tunnel → Simulate → Analyse
- [ ] Progressive disclosure: simple defaults for normal users, advanced
      settings available without cluttering the primary workflow
- [ ] No process is ever left silently running; every long operation
      shows real (never fabricated) progress and ends in an explicit
      success/failure/cancelled state, with notification if the user has
      switched away (see ADR-0003)
- [ ] Never silently modify a user's original geometry — always work on a
      copy, and disclose any automatic repairs performed

### Explicit exclusions

Things this project must **not** do (yet — see `architecture.md`,
"Explicitly NOT implemented yet", for the fuller list and reasoning):

- [ ] No STEP/IGES import in v1
- [ ] No transient/unsteady solving, moving reference frames, rotating
      wheels/propellers, or compressible flow in v1
- [ ] No cloud or remote execution — local only
- [ ] No Intel Mac support
- [ ] No Windows/Linux port
- [ ] No linking against OpenFOAM libraries, ever, regardless of
      performance temptation (ADR-0002)
- [ ] No fabricated/simulated progress, convergence, or results anywhere
      in the UI, under any circumstance

---

## 3. IMPORTANT DECISIONS

| Decision | Reason | Date |
|---|---|---|
| Project name: **LibreTunnel** | Chosen by project owner; checked for naming collisions before acceptance (an earlier candidate, "OpenAero", was rejected due to an existing, active, similarly-named open-source project in an adjacent domain) | 2026-09-06 |
| License: **GPL-3.0-or-later** | Project owner wants maximum guaranteed openness ("as open as we can") for a GitHub release; copyleft prevents closed forks capturing community work; matches the license of OpenFOAM and most prior OpenFOAM GUI front ends. See ADR-0001. | 2026-09-06 |
| OpenFOAM distribution: **OpenCFD (openfoam.com)**, not OpenFOAM Foundation (openfoam.org) | Only the OpenCFD distribution has a proven native macOS compilation path (via the community project `gerlero/openfoam-app`); the Foundation distribution requires a Multipass VM on macOS, which conflicts with the 8 GB RAM target. See ADR-0002. | 2026-09-06 |
| OpenFOAM integration boundary: **subprocess only, never linked** | Preserves license independence (GPL-3.0 obligations attach to linking/combining, not to independently-licensed programs communicating via files/CLI) and keeps the CFD backend swappable in principle. See ADR-0002. | 2026-09-06 |
| OpenFOAM runtime provisioning (v1): **auto-detect or auto-install via Homebrew, driven by the app itself, with real progress and guaranteed process cleanup** | Satisfies "no command line" requirement without the large upfront engineering cost of a fully bundled/signed runtime; a bundled runtime is deferred, not abandoned. See ADR-0002 and ADR-0003. | 2026-09-06 |
| Platform scope: **Apple Silicon only**, macOS 14 Sonoma minimum | Matches the project's own 8 GB M1 target; matches upstream reality (native OpenFOAM compilation for macOS has already dropped Intel support as of mid-2026). | 2026-09-06 |
| Code signing: **ad-hoc signed, not notarized — no paid Apple Developer ID** | Project owner explicitly wants to avoid the $99/year Developer ID; accepted trade-off is a one-time Gatekeeper right-click-to-open step on first launch, mitigated with clear DMG/README instructions. Fully reversible later if the project gets sponsorship. See ADR-0004. | 2026-09-06 |
| Build system: **Swift Package Manager only, no `.xcodeproj`** | Avoids Xcode-project lock-in, keeps the build reproducible from the command line and in CI without hand-authoring a project file that can't be verified in this authoring environment (see Section 16). | 2026-09-06 |
| Rendering: **raw Metal/MetalKit**, not SceneKit/RealityKit (tentative, open to revisiting) | Scientific visualisation (scalar fields, custom colour maps, streamlines, cutting planes) needs shader-level control those higher-level frameworks aren't built for. Not yet implemented or tested — flagged as open to challenge in `architecture.md`. | 2026-09-06 |
| Benchmark/reference case: OpenFOAM's own **`motorBike` tutorial** | Published, well-understood, ships with OpenCFD, matches the project's external-aerodynamics use case exactly — lets automated pipeline output be checked against known-good behaviour rather than unvalidated in-house geometry. | 2026-09-06 |
| Contribution model: **DCO sign-off, not a formal CLA** | Keeps contribution barrier low, consistent with the "as accessible as possible" goal. | 2026-09-06 |
| Geometry representation: **indexed triangle mesh, hand-rolled parsers, no third-party geometry library** | STL/OBJ are simple enough to parse directly; an indexed (deduplicated) mesh is required for later manifoldness/hole/disconnected-component validation, which flat triangle soup can't answer without redoing work. See ADR-0005. | 2026-09-06 |

**Do not reverse an established decision without explicitly discussing why it should change.**

---

## 4. CURRENT ARCHITECTURE

### Platform

- Operating system: macOS
- Minimum OS version: macOS 14 (Sonoma)
- Target architecture: arm64 (Apple Silicon) only — no x86_64 slice
- Application type: Native SwiftUI desktop application

### Languages

- Primary: Swift
- Secondary: Bash (packaging script), YAML (CI)

### Frameworks / libraries

- SwiftUI, AppKit (via SwiftUI), Foundation — all system frameworks, no
  third-party Swift package dependencies as of Phase 1
- OpenFOAM (OpenCFD distribution) — external runtime, invoked via
  subprocess only, never linked (see Section 3)

### Project structure

```text
LibreTunnel/
├── Package.swift
├── LICENSE                          (GPL-3.0, verbatim)
├── README.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
├── CHANGELOG.md
├── PROJECT_STATE.md                 (this file)
├── .gitignore
├── Sources/
│   ├── LibreTunnel/                 (SwiftUI app shell — executable target)
│   │   ├── LibreTunnelApp.swift
│   │   ├── ContentView.swift
│   │   ├── WorkflowStage.swift
│   │   ├── StagePlaceholderView.swift
│   │   ├── ImportView.swift          (Phase 2: real Import stage UI)
│   │   └── ImportViewModel.swift     (Phase 2: bridges UI to GeometryKit)
│   ├── AppCore/                     (shared pure-Swift models)
│   │   └── AppInfo.swift
│   └── GeometryKit/                 (Phase 2: STL/OBJ import + validation)
│       ├── TriangleMesh.swift
│       ├── IndexedMeshBuilder.swift
│       ├── STLImportError.swift
│       ├── STLImporter.swift
│       ├── OBJImportError.swift
│       ├── OBJImporter.swift
│       └── GeometryImporter.swift    (format dispatch by file extension)
├── Tests/
│   ├── AppCoreTests/
│   │   └── AppInfoTests.swift
│   └── GeometryKitTests/
│       ├── STLFixtures.swift
│       ├── STLImporterTests.swift
│       └── OBJImporterTests.swift
├── Scripts/
│   └── build-app-bundle.sh          (release packaging + ad-hoc signing)
├── Documentation/
│   ├── architecture.md
│   ├── developer-setup.md
│   ├── testing.md
│   ├── licensing.md
│   └── adr/
│       ├── 0001-project-license.md
│       ├── 0002-openfoam-runtime-strategy.md
│       ├── 0003-process-lifecycle-and-progress-reporting.md
│       ├── 0004-code-signing-without-developer-id.md
│       └── 0005-geometry-representation.md
└── .github/
    ├── workflows/ci.yml
    ├── ISSUE_TEMPLATE/
    │   ├── bug_report.md
    │   ├── feature_request.md
    │   └── cfd_issue.md
    └── PULL_REQUEST_TEMPLATE.md
```

### Major components

#### Component 1 — App shell
**Purpose:** SwiftUI window, sidebar navigation across the five workflow
stages. Import now has real content (`ImportView`/`ImportViewModel`);
Inspect/Tunnel/Simulate/Analyse remain placeholders.
**Location:** `Sources/LibreTunnel/`
**Status:** Import stage implemented, not yet run on real hardware
(written after the last confirmed-working build — see Section 16).
Placeholder stages confirmed working on real hardware as of Phase 1.

#### Component 2 — AppCore
**Purpose:** Shared, pure-Swift models with no UI or OpenFOAM dependency.
Currently just `AppInfo` (version/build metadata for reproducibility);
will later also host the cross-cutting `ProcessSupervisor` described in
ADR-0003.
**Location:** `Sources/AppCore/`
**Status:** `AppInfo` implemented with unit tests, confirmed passing on
real hardware.

#### Component 3 — GeometryKit
**Purpose:** STL/OBJ import, validation, repair. See ADR-0005 (and its
amendment) for the representation/parser-strategy decisions behind it.
**Location:** `Sources/GeometryKit/`
**Status:** `TriangleMesh` (indexed mesh model), `STLImporter` (binary +
ASCII, vertex dedup, descriptive errors — **fully verified on real
hardware, 13/13 tests**), `OBJImporter` (vertex/face parsing, fan
triangulation, geometric normals, 12 unit tests — **written, not yet
run on real hardware**), and `GeometryImporter` (format dispatch by
extension). Validation/repair not started.

#### Component 4 — DomainKit, CaseKit, OpenFOAMRuntime, SolverBridge, ResultsKit, RenderKit, ProjectKit
**Purpose:** See `Documentation/architecture.md` module table.
**Location:** Not yet created.
**Status:** Not started — planned for Phases 4–8 and 14 respectively.

---

## 5. CURRENT IMPLEMENTATION

### Completed

- [x] Phase 0: architecture, licensing, runtime, and platform decisions
      made and recorded (ADR-0001 through 0004)
- [x] Repository scaffold: license, governance docs, CI, issue/PR
      templates
- [x] Phase 1: SwiftUI app shell with five-stage sidebar navigation and
      honest placeholders — **verified on real Apple Silicon hardware**
      (M1, macOS 27 Beta, Xcode-beta 27.0): `swift build` passes,
      `swift test` passes (3/3, `AppCoreTests`), `swift run` launches
      the app with no crash, all five sidebar stages confirmed working
      by the project owner. Checkpoints 1 and 2 both genuinely closed.
- [x] `AppCore.AppInfo` with unit tests — passing for real (3/3)
- [x] Phase 2, slice 1: `GeometryKit` module — `TriangleMesh` (indexed
      mesh model, ADR-0005), `STLImporter` (binary + ASCII, vertex
      dedup, robust binary/ASCII disambiguation, descriptive errors).
      **Fully verified on real hardware**: 13/13 tests pass (including
      a real bug found, fixed, and re-verified), manual Import stage UI
      test with a real STL file confirmed working, Dock icon behavior
      under `swift run` explained and fixed.

### In progress

- [ ] Phase 2, slice 2: OBJ import (`OBJImporter`, `GeometryImporter`
      format dispatch). 12 new unit tests. Import stage now accepts
      both `.stl` and `.obj`. **Written, not yet run on real
      hardware** — see Section 16.
- [ ] Phase 2, final slice: geometry validation (holes, non-manifold
      edges, inverted normals, degenerate triangles, disconnected
      components, unrealistic scale) and repair. Not started.

### Not started

- [ ] Phase 2 UX refinement: literal drag-and-drop of a file onto the
      window, rather than only a "Choose File…" picker button.
- [ ] Phase 3 onward: see `Documentation/architecture.md`

### Known bugs

| Bug | Severity | Status | Notes |
|---|---|---|---|
| `swift build` failed with "plugin for module 'SwiftUIMacros' not found" (and `PreviewsMacros`) | Was blocking (Checkpoint 1) | **Resolved** | Confirmed root cause: `xcode-select` was pointed at the standalone Command Line Tools, which don't bundle the `SwiftUIMacros`/`PreviewsMacros` compiler plugins. The Mac in question has `Xcode-beta.app` (matching its macOS 27 Beta), not `Xcode.app`. Fixed with `sudo xcode-select --switch /Applications/Xcode-beta.app/Contents/Developer` + `sudo xcodebuild -license accept`. Confirmed via `xcodebuild -version` (Xcode 27.0) and `xcrun --sdk macosx --show-sdk-version` (27.0) matching exactly — no SDK mismatch. `swift build` then succeeded: "Build complete! (10.65 sec)". |
| `STLImporter.isLikelyBinary` misclassified short, valid ASCII STL files as binary, e.g. a minimal empty-solid file (`"solid empty\nendsolid empty"`, 26 bytes). Caught by `testThrowsOnEmptyASCIIFile` failing on real hardware: expected `.emptyFile`, got `.truncatedBinaryHeader`. | Was a real, test-caught bug (Phase 2 slice 1) | **Resolved and confirmed** | Root cause: the length check (`bytes.count >= 84`) ran *before* the "solid" prefix check, so any file under 84 bytes was assumed binary regardless of content — wrong whenever the file legitimately starts with "solid" and is just short. Fixed by checking the "solid" prefix first. **Confirmed on real hardware, 2026-09-07: all 10 `GeometryKitTests` pass, plus all 3 `AppCoreTests` — 13/13 total.** This is a genuine example of the test-first process working end to end: a real bug was caught by a real test on real hardware, root-caused correctly, fixed, and the fix was then itself confirmed by re-running the same test — not just argued to be correct by re-reading the code. |

### Known limitations

- No geometry import, meshing, OpenFOAM integration, or visualisation
  exists yet — Phase 1 is a navigation shell only.
- The entire Phase 1 codebase was authored in a Linux sandbox with no
  Swift toolchain and no macOS available, so nothing has been compiled
  or executed by its author. Treat all of it as IMPLEMENTED but NOT YET
  TESTED until confirmed on real hardware or via CI.

---

## 6. CURRENT TASK

**Task being worked on:**
Finishing the Phase 1 repository scaffold (governance files, ADRs,
LICENSE, app shell) and packaging it for the project owner to push to
GitHub and verify on real hardware.

**Why we are doing it:**
Phase 0 architectural agreement is complete (license, OpenFOAM runtime
strategy, platform scope, code signing all decided — see Section 3);
Phase 1 is the first concrete implementation checkpoint (native app
shell, Checkpoints 1–2).

**Expected result:**
A downloadable, git-ready `LibreTunnel/` directory containing everything
listed in Section 4's project structure, ready for `git init` + push, and
buildable via `swift build` on the owner's own Apple Silicon Mac.

**Current progress:**
All files listed in Section 4 have been created and delivered. `LICENSE`
required a workaround (see Section 11 journal entry) — repeated attempts
to have the AI author write the full verbatim GPL-3.0 text via tool
calls were aborted, most likely by an automated safety layer reacting to
bulk verbatim reproduction of freshly-fetched web content. Resolved by
having the project owner download the canonical text from gnu.org
directly and upload it, then copying it into place with `cp`. The
project owner then ran `git init`/commit (succeeded) and attempted
`swift build`/`swift test` on real Apple Silicon hardware — `swift build`
failed with a diagnosed, non-code, toolchain-environment issue (see
Known Bugs, Section 5, and journal entry below).

**Next action:**
Project owner to run the diagnostic commands given in this session
(`xcode-select -p`, checking for `/Applications/Xcode.app`) and either
switch the active developer directory to full Xcode.app, or — if that's
unavailable/insufficient on their macOS 27 Beta install — open
`Package.swift` directly in Xcode.app and build/run the `LibreTunnel`
scheme from there instead of the `swift build` CLI. In parallel, running
`swift test --filter AppCoreTests` or `swift build --target AppCore`
isolates the non-SwiftUI module from this issue and should give a real,
independent pass/fail result now, since `AppCore` doesn't import
SwiftUI. Once the toolchain issue is resolved (or worked around),
confirm `swift build && swift test && swift run` all succeed and update
Section 16 with the real result before proceeding to Phase 2.

---

## 7. TESTING

### Tests that pass

- [x] `swift build` — **passes** on real Apple Silicon hardware for both
      Phase 1 and Phase 2 slice 1.
- [x] `swift test` — **13/13 confirmed passing on real hardware**
      (2026-09-07): 3/3 `AppCoreTests`, 10/10 `GeometryKitTests`
      (including the previously-failing `testThrowsOnEmptyASCIIFile`,
      now genuinely fixed and re-verified, not just argued correct by
      re-reading the code).
- [ ] Phase 2 slice 2 (`OBJImporterTests`, 12 tests): written, reviewed,
      not yet run on real hardware.

### Tests that fail

- [ ] None known for confirmed code. Slice 2 is unverified, not
      failing — an important distinction (see Section 16).

### Manual testing performed

- [x] `git init && git add -A && git commit -s` — succeeded.
- [x] `swift build` — succeeded, Phase 1 and Phase 2 slice 1 both.
- [x] `swift test` — **13/13 pass, confirmed twice**: once catching the
      real `isLikelyBinary` bug, once confirming the fix.
- [x] `swift run` — app launched multiple times across this phase, no
      crash; Dock icon confirmed fixed.
- [x] Import stage UI end-to-end with a real STL file — confirmed
      working by the project owner.
- [ ] `swift build && swift test` including Phase 2 slice 2's new
      `OBJImporterTests` — not yet run.
- [ ] Import stage UI end-to-end with a real OBJ file — not yet
      performed.

### Last known working state

Phase 1 and Phase 2 slice 1 are both fully confirmed on real hardware,
including manual UI testing — build passes, all 13 tests pass, the
Import stage works end-to-end with a real STL file. Phase 2 slice 2
(OBJ import) is written and internally reviewed but **not yet compiled
or run anywhere**.

---

## 8. FILES OF PARTICULAR IMPORTANCE

| File | Purpose | Important notes |
|---|---|---|
| `Documentation/adr/0002-openfoam-runtime-strategy.md` | Defines the subprocess-only OpenFOAM boundary | This is a licensing-relevant architectural constraint, not just a style choice — do not let a future change link against an OpenFOAM library without a new ADR and explicit discussion |
| `Documentation/adr/0003-process-lifecycle-and-progress-reporting.md` | Defines `ProcessSupervisor` requirements | Must exist and be tested before `OpenFOAMRuntime`/`SolverBridge` are built, not after |
| `LICENSE` | GPL-3.0 full text | Sourced directly from a user-uploaded copy of the canonical gnu.org text, not AI-generated, after repeated generation attempts were blocked — see Section 11 journal entry |
| `Package.swift` | Defines the module/target structure | No `.xcodeproj` exists or should be hand-authored — see ADR discussion in `architecture.md` |

---

## 9. OPEN QUESTIONS

1. Who owns/hosts the actual GitHub repository (org vs. personal account),
   and what is the final repo URL? `README.md` and
   `Documentation/developer-setup.md` currently use a `<org>` placeholder.
2. Who is the designated contact for `SECURITY.md` and
   `CODE_OF_CONDUCT.md` enforcement? Both currently note this as
   unresolved rather than guessing.
3. ~~Has Phase 1 actually been confirmed to build and run on real Apple
   Silicon hardware yet?~~ **Resolved: yes, fully.** `swift build`,
   `swift test` (3/3 passing), and `swift run` all confirmed on real
   hardware as of 2026-09-06. The project owner also explicitly
   confirmed clicking through all five sidebar stages individually,
   resolving the earlier minor loose end about whether that had been
   checked specifically versus just the app launching.
4. ~~Is the project owner's Mac running only Xcode Command Line Tools,
   or is full Xcode.app also installed?~~ **Resolved.** Neither,
   exactly: the Mac has `Xcode-beta.app` (matching its macOS 27 Beta),
   not `Xcode.app`. `xcode-select` is now correctly pointed at it.
5. The project owner appears to be running a beta OS
   (`MacOSX27.0.sdk` in the build log). Is that intentional for
   day-to-day development of this project, or incidental? Building
   against a beta OS/toolchain widens the range of toolchain-level
   issues (like the one just hit) that have nothing to do with this
   project's own code. Still open — not yet answered either way.
6. ~~Has Phase 2 slice 1 (`GeometryKit`/STL import) been confirmed to
   build and pass its tests on real hardware yet?~~ **Resolved: yes,
   fully, including manual end-to-end UI testing.** 13/13 automated
   tests pass, and the project owner confirmed the Import stage works
   correctly with a real STL file through the actual app.
7. Has Phase 2 slice 2 (`OBJImporter`) been confirmed to build and pass
   its tests on real hardware yet? (As of this writing: **no** — 12
   new tests written and internally reviewed, including a manual trace
   of the fan-triangulation and negative-index-resolution logic, but
   not yet compiled or run anywhere. Given Phase 2 slice 1's own history
   in this file — code that looked correct in review still had a real
   bug — this should be treated with the same caution, not assumed
   correct because the STL importer turned out fine after its own bug
   was fixed.)

**Do not silently guess answers to important open questions.**

---

## 10. PENDING WORK

### Priority 1 — Critical

- [ ] Verify Phase 2 slice 2 (OBJ import) on real hardware:
      `swift build && swift test` (expect 25/25: 3 `AppCoreTests` + 10
      STL + 12 OBJ), then manually test the Import stage with a real
      `.obj` file. Update Section 16 with the real result — do not
      assume it works because the STL slice eventually did; that slice
      had a real bug review alone didn't catch.
- [ ] Confirm the repo-hygiene cleanup (duplicate root
      `STLImporter.swift`, misnamed `gitignore`) and browser
      download-location check from the previous round actually landed —
      not explicitly reconfirmed since the fix was given.

### Priority 2 — Important

- [ ] Once slice 2 is verified, begin Phase 2's final slice: geometry
      validation/repair (holes, non-manifold edges, inverted normals,
      degenerate triangles, disconnected components, unrealistic scale).
- [ ] Resolve open questions 1–2, 5 above (repo location, security
      contact, beta-OS intentionality).
- [ ] Consider adding literal drag-and-drop onto the Import view (in
      addition to the current file-picker button), to fully satisfy the
      original "drag in a 3D model" requirement — see Section 5, "Not
      started."

### Priority 3 — Nice to have

- [ ] Consider whether `ProcessSupervisor` (ADR-0003) should be scaffolded
      ahead of Phase 5, even as a tested-but-unused component, given how
      central it is to multiple later phases.

---

# 11. DEVELOPMENT JOURNAL

---

## [2026-09-06 00:00] — Phase 0: Architecture, licensing, and runtime research

**Action:**
Researched current (2026) OpenFOAM macOS support before proposing
architecture, rather than relying on possibly-stale training knowledge.

**Reason:**
The project's own instructions require researching the OpenFOAM/macOS
runtime strategy rather than assuming one, given how much this affects
licensing, performance, and the 8 GB RAM target.

**Changes:**
- Established that OpenFOAM Foundation (openfoam.org) requires a
  Multipass VM on macOS; OpenCFD (openfoam.com) has a genuine native
  compilation path via the community project `gerlero/openfoam-app`.
- Established that native compilation is roughly 13x faster than an
  emulated Docker environment in a published benchmark.
- Established that `gerlero/openfoam-app` dropped Intel Mac support as of
  its v2.2.0 (2026) release.
- Established OPENFOAM®/OpenCFD® trademark constraints.

**Files affected:**
- None yet (research phase, no repo existed).

**Result:**
Produced a full Phase 0 proposal: architecture, license options,
dependency strategy, OpenFOAM/macOS runtime strategy, phased roadmap,
checkpoints, top risks, and initial repo structure — presented to the
project owner for agreement, per the project's explicit "propose, then
stop and wait for agreement" instruction.

**Tests:**
N/A (research and proposal only).

**Problems discovered:**
None at this stage.

**Decision / reasoning:**
See Section 3, all "2026-09-06" entries — full reasoning also recorded
in `Documentation/adr/0001` through `0004`.

**Next step:**
Get explicit sign-off from the project owner on license, OpenFOAM
runtime strategy, platform scope, and naming before writing any code.

---

## [2026-09-06 01:00] — Phase 0 decisions confirmed; naming collision caught and resolved

**Action:**
Project owner confirmed: license should be "as open as we can" (resolved
to GPL-3.0-or-later), runtime Option A (auto-provision via Homebrew) with
an explicit requirement that no process is ever left silently running,
Apple Silicon only, and a proposed name "OpenAERO."

**Reason:**
Direct response to the Phase 0 proposal.

**Changes:**
- Checked "OpenAERO" for naming collisions before accepting it, as
  instructed to do proactively. Found an existing, active, similarly-
  named open-source project in an adjacent (aviation) domain, plus a
  second similarly-named aerospace engineering tool. Flagged this instead
  of silently proceeding, and proposed alternatives.
- Project owner chose "LibreTunnel" instead; checked for collisions
  (none found) before accepting.
- Formalised the "no process left silently running" requirement into a
  dedicated architectural component, `ProcessSupervisor`, and wrote
  ADR-0003 for it, rather than treating it as an implementation detail of
  the Homebrew install step alone.
- Confirmed avoiding a paid Apple Developer ID is possible via ad-hoc
  signing; wrote ADR-0004 covering the Gatekeeper trade-off and
  mitigations.

**Files affected:**
- None yet (still pre-repository at this point).

**Result:**
All Phase 0 decisions locked (see Section 3). Cleared to begin Phase 1.

**Tests:**
N/A.

**Problems discovered:**
- The "OpenAero" naming collision (caught before it became a problem,
  not after).

**Decision / reasoning:**
See ADR-0001 through ADR-0004 for full reasoning on each decision.

**Next step:**
Scaffold the actual repository and write Phase 1 (native app shell).

---

## [2026-09-06 02:00] — Phase 1 scaffold: repository, ADRs, app shell written

**Action:**
Created the full `LibreTunnel/` repository structure in a sandboxed
Linux container: `Package.swift`, the SwiftUI app shell
(`LibreTunnelApp.swift`, `ContentView.swift`, `WorkflowStage.swift`,
`StagePlaceholderView.swift`), the `AppCore` module (`AppInfo.swift` and
its tests), the release packaging script, all four ADRs, architecture/
developer-setup/testing/licensing docs, README, CONTRIBUTING,
CODE_OF_CONDUCT, SECURITY, CHANGELOG, `.gitignore`, GitHub issue/PR
templates, and a CI workflow targeting `macos-14` (confirmed to be
genuine Apple Silicon GitHub-hosted runners).

**Reason:**
Phase 1 = native application shell (Checkpoints 1–2), per the agreed
roadmap.

**Changes:**
- Added all files listed in Section 4's project structure except
  `LICENSE` (see next journal entry) and this file.

**Files affected:**
- All files under `Sources/`, `Tests/`, `Scripts/`, `Documentation/`,
  `.github/`, plus root-level governance files.

**Result:**
A structurally complete Phase 1 scaffold.

**Tests:**
None run — see Section 16. The authoring environment (a Linux sandbox
used for this session) has no Swift toolchain and is not macOS, so
`swift build`/`swift test` could not be executed here. This is disclosed
explicitly rather than claimed as verified.

**Problems discovered:**
None in the code itself (nothing has been run to discover problems
against); the LICENSE-file problem below is a tooling/process issue, not
a code problem.

**Decision / reasoning:**
Chose to keep Phase 1 deliberately minimal (app shell + one proof-of-
concept module, `AppCore`) rather than scaffolding all planned modules
at once, per the project's "smallest sensible version first" principle —
empty module stubs for `GeometryKit` etc. would be untested surface area
with no content yet.

**Next step:**
Write `LICENSE`, then this file, then package and deliver.

---

## [2026-09-06 03:00] — LICENSE file generation blocked; resolved via user-provided upload

**Action:**
Attempted multiple times to write the full verbatim GPL-3.0 text
(fetched from an official gnu.org mirror) into `LICENSE` via the file-
creation tool, in one large write and then in progressively smaller
chunks via shell heredocs. Several attempts were aborted with no output
and no clear error.

**Reason:**
`LICENSE` requires the exact, complete license text — this is both a
correctness requirement (an incomplete or inaccurate license text is
worse than none) and standard practice for GPL projects.

**Changes:**
- Diagnosed the pattern: every other file in this session (original
  prose, ADRs, a from-memory reproduction of the Contributor Covenant)
  wrote successfully; only attempts to reproduce a large block of text
  that had just been fetched live from the web in this same conversation
  were aborted.
- Reported this hypothesis transparently to the project owner rather
  than silently retrying indefinitely or fabricating a shortened/
  paraphrased license text as a workaround (a paraphrased GPL text would
  be legally wrong, not just imperfect).
- Resolved by asking the project owner to download the canonical text
  from gnu.org directly and upload it; copied the uploaded file into
  place with a single `cp` command, avoiding any AI-generated large text
  block entirely.

**Files affected:**
- `LICENSE`

**Result:**
`LICENSE` now contains the verified, complete, correct GPL-3.0 text
(674 lines; header and footer both checked directly against the file).

**Tests:**
Manually verified via `wc -l`, `head`, and `tail` after the copy — this
is a real, executed check, not an assumption.

**Problems discovered:**
An automated safety mechanism (outside this AI's direct control or
visibility) appears to block large verbatim reproductions of freshly-
fetched web content, even for content — like a software license — that
is explicitly meant to be copied verbatim. Worth knowing for any future
session that needs to reproduce another long canonical document
(another license text, a standard, etc.): prefer asking the user to
supply the file directly rather than repeatedly retrying AI-generated
verbatim reproduction.

**Decision / reasoning:**
Chose user-upload-and-copy over further retries or paraphrasing,
because correctness of a legal document matters more than finishing the
task via the originally planned mechanism, and because repeated silent
retries without explaining the blocker to the user would have been
opaque and unproductive.

**Next step:**
Write this file (`PROJECT_STATE.md`) itself, do a final review of all
files, then zip and deliver.

---

## [2026-09-06 04:00] — First real build attempt on Apple Silicon hardware: `swift build` fails, root cause diagnosed

**Action:**
Project owner unzipped the delivered scaffold on a real Apple Silicon
Mac, ran `git init && git add -A && git commit -s`, then `swift test`
(interrupted manually at `[69/119]`, no result either way), then
`swift build` (ran to completion — failed).

**Reason:**
This was the planned verification step for Checkpoints 1–2, since the
authoring environment had no Swift toolchain (see the 2026-09-06 02:00
journal entry).

**Changes:**
None to the codebase yet — this entry is a diagnosis, not a fix.

**Files affected:**
None (diagnosis only).

**Result:**
`swift build` failed with:
```
error: external macro implementation type 'SwiftUIMacros.StateMacro'
could not be found for macro 'State()'; plugin for module
'SwiftUIMacros' not found
```
and an equivalent error for `PreviewsMacros`/`#Preview`, in
`ContentView.swift` and `StagePlaceholderView.swift`.

**Tests:**
`swift test`: inconclusive (interrupted before completion).
`swift build`: failed, real and reproducible.

**Problems discovered:**
Diagnosed root cause, not a defect in the four files that hit it:

1. The build log shows the compiler invocation using
   `/Library/Developer/CommandLineTools/SDKs/MacOSX27.0.sdk` and
   `/Library/Developer/CommandLineTools/usr/bin/swift-frontend` — i.e.
   the build used the **standalone Xcode Command Line Tools**, not full
   Xcode.app.
2. The `-load-resolved-plugin` flags in the failed invocation only
   loaded `libObservationMacros.dylib` and `libSwiftMacros.dylib`, both
   from the CommandLineTools toolchain's own plugin directory. There is
   no `SwiftUIMacros` or `PreviewsMacros` plugin loaded at all.
3. Research during this session confirmed those two plugins
   (`libSwiftUIMacros.dylib`, `libPreviewsMacros.dylib`) ship only
   inside full Xcode.app, under
   `Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib/swift/host/plugins/`
   — a location the standalone Command Line Tools package does not
   include at all.
4. Found a matching, currently open upstream bug report (unrelated
   project, `drumih/turbo-fieldfare#121`) hitting the byte-for-byte
   identical error message on the byte-for-byte identical environment
   (macOS 27 Beta 4, Swift 6.4, target `arm64-apple-macosx27.0.0`),
   confirming this is a known, reproducible toolchain/beta-OS pattern,
   not something specific to this project's source.
5. `@State` and `#Preview` are standard, correct, idiomatic SwiftUI —
   deliberately not "fixed" by rewriting them to avoid the macro system,
   since that would be treating an environment problem by degrading the
   codebase.

**Decision / reasoning:**
Do not modify `ContentView.swift` or `StagePlaceholderView.swift` in
response to this. The fix belongs in the local toolchain configuration
(switch `xcode-select` to full Xcode.app, or build via Xcode.app
directly instead of the `swift build` CLI), not in the source. Recorded
as a Known Bug (Section 5) with status "diagnosed, not yet confirmed
fixed" rather than closed, since the actual fix hasn't been verified
yet.

**Next step:**
Project owner runs `xcode-select -p` and checks for
`/Applications/Xcode.app`; switches the active developer directory if
needed; if that's insufficient, builds via Xcode.app's own UI instead of
`swift build`. In parallel, `swift test --filter AppCoreTests` (or
`swift build --target AppCore`) should be run to get an independent,
real result for the non-SwiftUI module while this is sorted out.

## [2026-09-06 05:00] — Build failure resolved: xcode-select pointed at Xcode-beta.app

**Action:**
Diagnosed and fixed the `swift build` failure from the 04:00 entry.

**Reason:**
Confirm Checkpoint 1 for real before proceeding further.

**Changes:**
None to the codebase — this was purely a local toolchain configuration
fix on the project owner's machine.

**Files affected:**
None.

**Result:**
`sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
initially failed with "invalid developer directory" — that path doesn't
exist on this machine. The actual installed app is **`Xcode-beta.app`**
(consistent with running macOS 27 Beta). Switching to
`/Applications/Xcode-beta.app/Contents/Developer` and running
`sudo xcodebuild -license accept` succeeded.
`xcodebuild -version` reports Xcode 27.0, and `xcrun --sdk macosx
--show-sdk-version` reports SDK 27.0 — matching exactly, so there was no
additional SDK/Xcode-version mismatch to worry about.
`swift build` (run from the correct `LibreTunnel/` directory, after an
initial `Package.swift not found` slip from running it in `~`) then
succeeded: "Build complete! (10.65 sec)".

**Tests:**
`swift build`: **pass**, confirmed on real hardware.
`swift test` / `swift run`: not yet run — next step.

**Problems discovered:**
None new. The original diagnosis (Section 5 Known Bugs, now resolved)
was confirmed correct in every particular: wrong active developer
directory, missing SwiftUI macro plugins, no code defect.

**Decision / reasoning:**
No source changes were needed or made, consistent with the earlier
decision not to work around a local environment issue by modifying
correct SwiftUI code.

**Next step:**
Run `swift test` (expect the three `AppCoreTests` to pass) and `swift
run` (expect the app window to open with working sidebar navigation
across all five placeholder stages — this is the actual Checkpoint 2
verification). Update this file with those results.

## [2026-09-06 06:00] — Phase 1 fully verified: build, tests, and run all confirmed on real hardware

**Action:**
Project owner ran `swift test` and `swift run` after the toolchain fix.

**Reason:**
Close out Checkpoints 1–2 with real evidence rather than assumption.

**Changes:**
None to the codebase.

**Files affected:**
None.

**Result:**
`swift test`: all 3 `AppCoreTests` passed ("Executed 3 tests, with 0
failures"). `swift run`: app built (0.21s) and launched; project owner
reports it "works perfect currently, no crashing, fast and clean."
Terminal blocked on the running foreground process until interrupted
with Ctrl-C, which is expected behavior for a GUI app launched this way,
not a crash.

**Tests:**
`swift build`: pass. `swift test`: pass, 3/3. `swift run`: pass
(qualitative — app launches and runs without crashing).

**Problems discovered:**
None. Also noted: the project owner's local `PROJECT_STATE.md` had not
actually been overwritten with the versions presented in earlier turns
before attempting to commit ("nothing to commit, working tree clean") —
a process note for keeping this file synchronized, not a project defect.

**Decision / reasoning:**
Phase 1 (native application shell) is complete and verified.
Checkpoints 1 ("clean project builds from source") and 2 ("native
macOS application launches on Apple Silicon") are both closed with real
evidence, per Section 16.

**Next step:**
Begin Phase 2: `GeometryKit` (STL/OBJ import and validation). Also worth
doing before or alongside Phase 2: push this repository to GitHub and
confirm the CI workflow (`.github/workflows/ci.yml`) goes green on a
`macos-14` runner, as an independent, repeatable confirmation beyond
this one local machine.

## [2026-09-06 07:00] — Phase 2, slice 1: STL geometry import (GeometryKit)

**Action:**
Implemented the first slice of Phase 2: a new `GeometryKit` module with
an indexed-mesh model and a binary/ASCII STL importer, plus real Import
stage UI wiring in the app (file picker, parse summary, error display).
Wrote a new ADR (0005) for the mesh representation and parser-strategy
decisions this required.

**Reason:**
Phase 2 = geometry import and validation, per the agreed roadmap.
Deliberately scoped to STL only for this slice — not OBJ, not
validation/repair — per the project's "smallest sensible version,
test before moving to the next dependent stage" principle, especially
given Phase 1 just demonstrated that untested assumptions about this
codebase can hide real problems (the SwiftUI macro plugin issue).

**Changes:**
- Added `Sources/GeometryKit/`: `TriangleMesh.swift` (indexed mesh
  model), `IndexedMeshBuilder.swift` (shared vertex-dedup logic used by
  every future importer), `STLImportError.swift`, `STLImporter.swift`
  (binary + ASCII STL, robust binary/ASCII disambiguation for the
  well-known "solid-prefixed binary header" ambiguity).
- Added `Tests/GeometryKitTests/`: `STLFixtures.swift` (builds valid and
  broken STL byte content in code, no external fixture files needed),
  `STLImporterTests.swift` (10 tests: binary parsing, ASCII parsing,
  vertex deduplication in both formats, the solid-prefix ambiguity edge
  case, bounding-box computation, and all four documented error cases).
- Added `Sources/LibreTunnel/ImportView.swift` and `ImportViewModel.swift`:
  real Import stage content (file picker via `.fileImporter`, background
  parsing via `Task.detached` so large files don't block the UI thread,
  parse-result summary, understandable error display).
- Updated `WorkflowStage.swift`: `.importGeometry.isImplemented` is now
  `true` (the other four stages remain `false`).
- Updated `ContentView.swift`: routes `.importGeometry` to `ImportView`
  instead of `StagePlaceholderView`; the other four stages are
  unaffected.
- Updated `Package.swift`: added `GeometryKit` library target and
  `GeometryKitTests` test target; `LibreTunnel` executable now depends
  on `GeometryKit`.
- Updated `Documentation/architecture.md`, `Documentation/testing.md`,
  `CHANGELOG.md` to match.

**Files affected:**
See list above; also this file (Sections 1, 2, 3, 4, 5, 9, 10, this
entry, 12, 16).

**Result:**
Code written, internally reviewed (brace/paren balance checked, import
statements re-checked, `Package.swift` target paths confirmed against
actual directories). Not yet compiled or run anywhere — the authoring
environment has no Swift toolchain. Marked accordingly rather than
assumed working — see Section 16 and open question 6 (Section 9).

**Tests:**
10 new tests written in `GeometryKitTests`, covering the cases listed
above. Not yet executed on real hardware.

**Problems discovered:**
None in review, but "discovered nothing in review" is exactly the state
Phase 1 was in before the real build surfaced a genuine toolchain issue
— so this is explicitly not being treated as equivalent to "confirmed
working."

One real, non-toolchain gap was found and disclosed rather than glossed
over: the original functional requirement is "drag in a 3D model," but
what's implemented is a file-picker button (`.fileImporter`), not
literal drag-and-drop onto the window. The import/parsing logic itself
satisfies the underlying need; the specific drag-and-drop interaction
does not yet exist. Logged as a tracked, not-started item (Section 5)
rather than silently marking the requirement complete.

**Decision / reasoning:**
Kept `GeometryKit` fully synchronous and free of SwiftUI/threading
concerns (see its module documentation) — the app's `ImportViewModel` is
responsible for keeping the UI responsive during large-file parsing, via
`Task.detached`. This keeps `GeometryKit` simple to unit-test and reuse
later (e.g., a hypothetical command-line tool or a batch-import feature
would use the exact same importer with no UI dependency).

**Next step:**
Project owner runs `swift build && swift test` on real hardware. If
`GeometryKitTests` pass, manually exercise the Import stage UI with a
real STL file and a deliberately broken one. Report results either way
so Section 16 can reflect reality, then continue Phase 2 with OBJ import.

## [2026-09-07 08:00] — Real bug found on hardware: STL binary/ASCII disambiguation, fixed

**Action:**
Project owner merged Phase 2 slice 1 into the existing repo, ran
`swift build` (passed) and `swift test`. `GeometryKitTests` reported
9/10 passing, 1 failure: `testThrowsOnEmptyASCIIFile` expected
`.emptyFile` but got `.truncatedBinaryHeader`.

**Reason:**
This is exactly the verification step flagged as pending in the
previous journal entry and Section 16 — run the real tests before
trusting review alone.

**Changes:**
- Root-caused the failure to `STLImporter.isLikelyBinary`: the file-size
  check (`bytes.count >= 84`) ran before the "solid" prefix check, so
  any file under 84 bytes was assumed binary regardless of content.
  This is wrong whenever a file legitimately starts with "solid" and is
  simply short — exactly the empty/near-empty ASCII STL case the failing
  test exercised.
- Fixed by reordering: check the "solid" prefix first. Not starting with
  "solid" → binary, regardless of length. Starting with "solid" but
  under 84 bytes → cannot possibly be valid binary STL (which requires
  at least an 80-byte header plus a 4-byte count), so it must be ASCII.
  Starting with "solid" and at least 84 bytes → disambiguate via the
  existing size-formula check, unchanged.
- Verified the fix by manual trace against all 10 `STLImporterTests`
  cases (documented in code comments and in this entry) — not yet
  re-run on real hardware.
- Corrected a separate, smaller error: the test count was mis-stated as
  9 in `PROJECT_STATE.md` and the previous journal entry; it's actually
  10. Fixed throughout this file.
- Added `*.zip` to `.gitignore` and flagged (not yet fixed — project
  owner's action) that a stray `testing.md` at the repo root and the
  delivered `LibreTunnel-phase2-slice1.zip` both appear as untracked
  files in `git status` and should be removed before the next commit —
  see Section 10.

**Files affected:**
- `Sources/GeometryKit/STLImporter.swift` (the fix)
- `.gitignore`
- This file (test count correction, this entry, Sections 5, 7, 12, 16)

**Result:**
Fix written and manually verified by trace, not yet compiled or tested
on real hardware.

**Tests:**
Real hardware run (before fix): 9/10 `GeometryKitTests` passed, 3/3
`AppCoreTests` passed, `swift build` passed. Not yet re-run since the
fix.

**Problems discovered:**
The `isLikelyBinary` ordering bug above — a genuine defect, not a
toolchain issue, found only because a real test was actually executed.
Also: stray `testing.md` at repo root and a committed zip archive,
likely artifacts of how files were merged/saved locally rather than a
project defect — flagged for cleanup, not treated as a code problem.

**Decision / reasoning:**
Did not weaken or remove the test that caught this — the test was
correct; the implementation was wrong. This is noted explicitly because
the opposite instinct (loosen the test to match the buggy behavior) is
exactly the kind of shortcut the project's "no fake functionality" and
"test first" principles exist to prevent.

**Next step:**
Project owner re-runs `swift test`, confirms all 10 `GeometryKitTests`
plus 3 `AppCoreTests` pass (13 total), cleans up the stray root
`testing.md` and committed zip per Section 10, then manually tests the
Import stage UI with a real STL file before this slice is considered
closed.

## [2026-09-07 09:00] — Fix confirmed on real hardware: 13/13 tests pass; recurring file-placement issue identified

**Action:**
Project owner re-ran `swift build` and `swift test` after applying the
`isLikelyBinary` fix, then committed.

**Reason:**
Confirm the fix actually works, not just that it traces correctly on
paper — the standard this project holds itself to per the previous
entry.

**Changes:**
None to the codebase — this is a confirmation, not a further fix.

**Files affected:**
None from this action directly; this file only.

**Result:**
`swift build`: pass. `swift test`: **13/13 pass** — 3/3 `AppCoreTests`,
10/10 `GeometryKitTests`, including `testThrowsOnEmptyASCIIFile`, the
test that caught the original bug. The fix is genuinely confirmed, not
assumed.

However, the resulting commit (`git commit -s -m "Fix STL binary/ASCII
disambiguation..."`) revealed two new stray files: a duplicate
`STLImporter.swift` at the repository root (alongside the correct one at
`Sources/GeometryKit/STLImporter.swift`), and a file literally named
`gitignore` (no leading dot) committed alongside the existing
`.gitignore`, meaning the intended `.gitignore` update (`*.zip` rule)
was never actually applied to the real `.gitignore`.

**Tests:**
13/13, confirmed on real hardware, 2026-09-07.

**Problems discovered:**
This is the third occurrence of a delivered file landing at the
repository root instead of where it was meant to go (previously:
`testing.md`, `LibreTunnel-phase2-slice1.zip`; now:
`STLImporter.swift`, `gitignore`). The consistent pattern — files
appearing untracked or freshly committed at the repo root right after a
file was delivered for the project owner to place manually — strongly
suggests the browser's default download location is set to the
`LibreTunnel` repository folder itself, rather than `~/Downloads`.
Flagged directly to the project owner as something to check, rather
than continuing to patch each individual symptom.

**Decision / reasoning:**
Gave exact, minimal cleanup commands rather than re-delivering a full
repository zip for a two-file mistake — proportionate response to a
small, well-understood problem.

**Next step:**
Project owner runs the given cleanup commands and confirms `git status`
is clean afterward (no stray root files). Separately, manually test the
Import stage UI end-to-end with a real STL file — this is the one
piece of Phase 2 slice 1 not yet exercised at all, since all testing so
far has been at the `GeometryKit` unit level, not through the actual UI.
Once both are done, Phase 2 slice 1 is fully closed and OBJ import
(next slice of Phase 2) can begin.

## [2026-09-07 10:00] — Dock icon missing under swift run: explained, small fix added

**Action:**
Project owner reported the app works correctly (window visible in
Mission Control and on the desktop) but shows no Dock icon when
launched via `swift run`. Investigated and confirmed this is a known,
documented characteristic of unbundled Swift executables, not a defect.

**Reason:**
Running via `swift run` produces a bare Mach-O executable, not a real
`.app` bundle recognized by LaunchServices. Without a bundle (and its
`Info.plist`), macOS doesn't reliably grant the process full "regular
app" status (Dock icon, Cmd+Tab presence) even though its window system
integration still works fine for actually displaying windows.

**Changes:**
- Added `AppDelegate` (`NSApplicationDelegate`) to `LibreTunnelApp.swift`,
  wired via `@NSApplicationDelegateAdaptor`, which explicitly calls
  `NSApp.setActivationPolicy(.regular)` and `NSApp.activate()` on
  launch. This is a no-op once the app is a real packaged bundle (which
  already defaults to `.regular`), but fixes the Dock icon during
  `swift run`-based development.
- Added an explanatory note to `Documentation/developer-setup.md` so
  this doesn't cause confusion for future contributors either.

**Files affected:**
- `Sources/LibreTunnel/LibreTunnelApp.swift`
- `Documentation/developer-setup.md`

**Result:**
Change written, brace/paren balance verified, reviewed for correctness
(`@NSApplicationDelegateAdaptor` and `NSApplicationDelegate` are plain
AppKit/SwiftUI APIs, not macros, so this does not risk the
`SwiftUIMacros` plugin issue from the Phase 1 build failure). Not yet
run on real hardware — see Section 16.

**Tests:**
No automated test applicable (this is an AppKit activation-policy
behavior, not logic `GeometryKitTests`/`AppCoreTests` would cover).
Verification is manual: run `swift run` and confirm a Dock icon appears.

**Problems discovered:**
None beyond the Dock-icon behavior itself, which is expected/known, not
a defect.

**Decision / reasoning:**
Fixed at the dev-workflow level rather than just documenting the
limitation, since the cost was one small, well-understood, standard
AppKit call with no effect on production (bundled) behavior.

**Next step:**
Project owner runs `swift run` again and confirms a Dock icon now
appears. Then proceed to the still-open items from the previous entry:
repo-hygiene cleanup confirmation and manual end-to-end Import stage
testing with a real STL file.

## [2026-09-07 11:00] — Phase 2, slice 2: OBJ geometry import

**Action:**
Implemented OBJ import: `OBJImporter` in `GeometryKit`, plus a new
`GeometryImporter` that dispatches between STL and OBJ by file
extension. Wired into the Import stage UI (now accepts both formats).
Amended ADR-0005 with the OBJ-specific decisions this required.

**Reason:**
Phase 2 slice 2, per the roadmap — the second of geometry import's two
formats, kept as its own slice with its own real-hardware verification
cycle rather than bundled into slice 1, consistent with how Phase 1 and
slice 1 were handled.

**Changes:**
- Added `Sources/GeometryKit/OBJImportError.swift`, `OBJImporter.swift`
  (vertex/face parsing, fan triangulation of n-gon faces, all
  face-vertex syntax variants, negative/relative index resolution,
  geometric normal computation), and `GeometryImporter.swift` (format
  dispatch by extension — the single entry point the app now uses,
  rather than hard-coding format selection in the UI layer).
- Added `Tests/GeometryKitTests/OBJImporterTests.swift`: 12 tests
  covering triangle/quad parsing, all `v`/`v/vt`/`v/vt/vn`/`v//vn`
  syntax variants, negative indices, keyword-skipping (comments,
  `o`/`g`/`s`/`mtllib`/`usemtl`), the geometric-normal-over-file-normal
  decision, and all four documented error cases.
- Updated `ImportViewModel.swift` (`importGeometry` replaces the
  STL-specific `importSTL`, now calls `GeometryImporter`) and
  `ImportView.swift` (accepts both `.stl` and `.obj`, updated copy).
- Amended `Documentation/adr/0005-geometry-representation.md` with the
  three OBJ-specific decisions: routing through the same dedup pass as
  STL despite OBJ's native indexing, always computing geometric normals
  rather than trusting file `vn` data (for both formats, not just OBJ),
  and fan triangulation's documented convex-only correctness.
- Updated `architecture.md`, `testing.md`, `CHANGELOG.md` to match.
- No `Package.swift` changes needed — OBJ import lives in the existing
  `GeometryKit`/`GeometryKitTests` targets.

**Files affected:**
See list above; also this file (Sections 1, 2, 4, 5, 7, 9, 10, this
entry, 12, 16).

**Result:**
Code written, internally reviewed (brace/paren balance checked on every
new/modified file, import statements verified, fan-triangulation and
negative-index-resolution logic manually traced against all 12 new
tests). Not yet compiled or run anywhere — same caveat as every prior
slice, stated with the same seriousness now that slice 1 has
demonstrated review-only confidence isn't sufficient.

**Tests:**
12 new tests written in `OBJImporterTests`. Not yet executed on real
hardware.

**Problems discovered:**
None in review. Explicitly not being treated as equivalent to
"confirmed working" — see Result above.

**Decision / reasoning:**
Kept OBJ import as its own slice with its own verification cycle,
rather than bundling it with validation/repair (the final slice of
Phase 2) or rushing it out alongside slice 1 initially. Chose to route
OBJ through the same `IndexedMeshBuilder` dedup pass as STL rather than
trusting OBJ's native indexing directly, and to always compute geometric
normals rather than using file-provided ones for either format — both
decisions recorded with full reasoning in ADR-0005's amendment, not just
implemented silently.

**Next step:**
Project owner runs `swift build && swift test` (expect 25/25 total),
then manually tests the Import stage with a real OBJ file. Report
results either way. Once confirmed, Phase 2's final slice (geometry
validation/repair) can begin.

---

# 12. SESSION CHECKPOINT

**Last completed action:**
Implemented Phase 2, slice 2: OBJ geometry import (`OBJImporter`,
`GeometryImporter` format dispatch) with 12 unit tests, wired into the
Import stage UI alongside STL. Written and internally reviewed; not yet
compiled or run on real hardware.

**Current state:**
Phase 1 and Phase 2 slice 1 remain fully verified. Phase 2 slice 2 is
written and unit-test-covered but **unverified** — stated with full
seriousness given slice 1's own history of a real bug surviving review.

**Current problem:**
None known, but "none known" reflects review only, not execution.

**Next exact action:**
1. Project owner runs `swift build && swift test` on real Apple Silicon
   hardware; expect 25/25 total (3 `AppCoreTests` + 10 STL + 12 OBJ).
2. If all pass, manually test the Import stage with a real `.obj` file.
3. Report results either way and update Section 16 with real data.
4. Once confirmed, begin Phase 2's final slice: geometry validation and
   repair.

**Do not restart completed work unless there is evidence that it is incorrect.**

---

# 13. HANDOFF INSTRUCTIONS

If another AI agent is continuing this project:

1. Read this entire file.
2. Inspect the actual project files before making assumptions.
3. Check the latest `DEVELOPMENT JOURNAL` entries.
4. Check `SESSION CHECKPOINT`.
5. Determine whether the stated project state matches the actual files.
6. If there is a discrepancy, trust the actual working files over an outdated state description and document the discrepancy.
7. Continue from **Next exact action** unless there is a good technical reason not to.
8. Do not unnecessarily rebuild, rewrite, or restart completed work.
9. Before making major architectural changes, record the proposed change and reason in the journal.
10. After every meaningful development step, update this file.
11. Before ending a session, update `SESSION CHECKPOINT`.
12. Leave the project in a state where another AI can immediately continue.

**Specific to this project:** do not re-open the license, OpenFOAM
runtime, platform-scope, or code-signing decisions in Section 3 without
explicit discussion — each has a full ADR in `Documentation/adr/`
explaining why it was made. Do not add any code that links against an
OpenFOAM library (ADR-0002). Do not fabricate progress, convergence, or
results anywhere in the UI (ADR-0003 and the project's core principles).

---

# 14. CHANGE CONTROL

No major changes have been proposed since the Phase 0 decisions recorded
in Section 3, which were themselves the initial architecture (not a
change to prior work, since none existed).

---

# 15. AI AGENT RULES

These rules apply to every AI working on this repository.

- Preserve existing functionality unless explicitly instructed otherwise.
- Inspect before modifying.
- Test meaningful changes.
- Do not claim something works without testing it when testing is possible.
- Do not silently ignore errors.
- Do not silently change requirements.
- Do not overwrite working implementations merely to use a preferred approach.
- Keep changes focused on the current task.
- Record important discoveries.
- Record important decisions.
- Keep this file synchronized with the actual project.
- Prefer small, verifiable changes over enormous untested changes.
- If something is ambiguous and the decision could materially affect the project, ask rather than inventing a requirement.
- If a reasonable low-risk assumption is necessary, document the assumption in the journal.
- The repository itself is the source of truth for implementation.
- This file is the source of truth for project history, decisions, requirements, and current state.
- Never link against an OpenFOAM library, under any circumstance, without a new ADR and explicit human discussion first (ADR-0002).
- Never fabricate progress, convergence, or results in the UI, under any circumstance (ADR-0003 and core project principles).

---

# 16. LAST VERIFIED STATE

**Date:**
2026-09-07

**Build:**
**PASS for Phase 1 and Phase 2 slice 1**, confirmed on real Apple
Silicon hardware (M1, macOS 27 Beta, Xcode-beta 27.0). **NOT YET
TESTED for Phase 2 slice 2** (OBJ import) — written after the last
confirmation, not yet built on real hardware.

**Tests:**
**13/13 PASS, confirmed on real hardware, 2026-09-07** — Phase 1 +
Phase 2 slice 1 (3/3 `AppCoreTests`, 10/10 STL `GeometryKitTests`),
including a real bug found, fixed, and re-verified in the same session.
**12 new OBJ tests (`OBJImporterTests`) written, NOT YET RUN.** Expect
25/25 total once slice 2 is verified — do not assume that number until
it's real.

**Application launches:**
**YES, fully confirmed for Phase 1** (all five sidebar stages clicked
through) **and for the Import stage's STL functionality** (real file
tested end-to-end by the project owner). Dock icon behavior under
`swift run` explained and fixed. **NOT YET TESTED** for the Import
stage's OBJ functionality specifically.

**Major functionality verified:**
Build system, `AppCore.AppInfo`, the SwiftUI app shell's launch/
navigation, and `GeometryKit`'s STL import are all confirmed working on
real hardware end-to-end, including through the actual UI. OBJ import
(`OBJImporter`, `GeometryImporter`) is implemented and unit-test-covered
but not yet confirmed on real hardware — treat as unverified until it
is, exactly as STL was treated before its own verification (which, not
incidentally, is what caught a real bug).

**Known issues:**
None open in confirmed code. Phase 2 slice 2 (OBJ import) has no known
issues, but "none known" reflects review only — see Tests, above. Two
repo-hygiene items from a prior round (duplicate root
`STLImporter.swift`, misnamed `gitignore`) had a fix given; not
re-confirmed applied in this round — see Section 10.

**Ready for another AI agent to continue:**
YES. Phase 1 and Phase 2 slice 1 are both genuinely verified, including
through the real UI. Phase 2 slice 2 (OBJ import) is written but
unverified — the next session's first job is running
`swift build && swift test` on real hardware and updating this section
with the real result, not assuming it works because slice 1 eventually
did.
