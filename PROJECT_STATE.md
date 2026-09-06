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
Complete Phase 1 (native application shell) and get it verified — the
code has been written but not yet compiled or run on real hardware (see
Section 16). Next real objective after verification is Phase 2:
geometry import (STL/OBJ) and validation.

**Project status:**
`DEVELOPMENT` (Phase 1 of 12 — see `Documentation/architecture.md` for
the full phase list)

**Last updated:**
2026-09-06

**Last updated by:**
AI (Claude), in direct collaboration with the project owner across a
multi-session architecture discussion and initial scaffold build.

---

## 2. CORE REQUIREMENTS

### Functional requirements

- [ ] Drag-and-drop import of STL and OBJ 3D models
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
│   │   └── StagePlaceholderView.swift
│   └── AppCore/                     (shared pure-Swift models)
│       └── AppInfo.swift
├── Tests/
│   └── AppCoreTests/
│       └── AppInfoTests.swift
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
│       └── 0004-code-signing-without-developer-id.md
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
stages, placeholder content views.
**Location:** `Sources/LibreTunnel/`
**Status:** Implemented, not yet compiled/run (see Section 16).

#### Component 2 — AppCore
**Purpose:** Shared, pure-Swift models with no UI or OpenFOAM dependency.
Currently just `AppInfo` (version/build metadata for reproducibility);
will later also host the cross-cutting `ProcessSupervisor` described in
ADR-0003.
**Location:** `Sources/AppCore/`
**Status:** `AppInfo` implemented with unit tests, not yet compiled/run.

#### Component 3 — GeometryKit, DomainKit, CaseKit, OpenFOAMRuntime, SolverBridge, ResultsKit, RenderKit, ProjectKit
**Purpose:** See `Documentation/architecture.md` module table.
**Location:** Not yet created.
**Status:** Not started — planned for Phases 2–8 and 14 respectively.

---

## 5. CURRENT IMPLEMENTATION

### Completed

- [x] Phase 0: architecture, licensing, runtime, and platform decisions
      made and recorded (ADR-0001 through 0004)
- [x] Repository scaffold: license, governance docs, CI, issue/PR
      templates
- [x] Phase 1 (written, not yet verified — see Section 16): SwiftUI app
      shell with five-stage sidebar navigation and honest placeholders
- [x] `AppCore.AppInfo` with unit tests (written, not yet run)

### In progress

- [ ] Verification of Phase 1 (Checkpoints 1–2): needs `swift build` /
      `swift test` / `swift run` on real Apple Silicon hardware, or a
      green CI run, before it can be marked tested

### Not started

- [ ] Phase 2: STL/OBJ geometry import and validation (`GeometryKit`)
- [ ] Phase 3 onward: see `Documentation/architecture.md`

### Known bugs

| Bug | Severity | Status | Notes |
|---|---|---|---|
| None known | — | — | Nothing has been run yet to discover bugs against (see Section 16) |

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
All files listed in Section 4 have been created. `LICENSE` required a
workaround (see Section 11 journal entry on this) — repeated attempts to
have the AI author write the full verbatim GPL-3.0 text via tool calls
were aborted, most likely by an automated safety layer reacting to bulk
verbatim reproduction of freshly-fetched web content. Resolved by having
the project owner download the canonical text from gnu.org directly and
upload it, then copying it into place with `cp` — no AI-generated large
text block involved. This is now confirmed correct: 674 lines, correct
header and footer.

**Next action:**
Zip the repository and deliver it to the project owner via
`present_files`, with clear instructions for `git init`, first push, and
manually verifying Checkpoints 1–2 (`swift build`, `swift test`,
`swift run`) on their own Apple Silicon Mac, since this could not be
verified in the authoring environment.

---

## 7. TESTING

### Tests that pass

- [ ] Not yet run anywhere. `AppCoreTests` has been written
      (`testDescribingFormatsAllFields`, `testEquality`,
      `testCurrentFallsBackToDevelopmentDefaultsOutsideAnAppBundle`) but
      has not been executed — no Swift toolchain was available in the
      authoring environment.

### Tests that fail

- [ ] None known — nothing has been run yet.

### Manual testing performed

- [ ] None yet. Manual checklist for Phase 1 is in
      `Documentation/testing.md`.

### Last known working state

No "working" state has been established yet in the sense of having been
run. The last known-*consistent* state is: repository scaffold complete,
all files reviewed for internal consistency (Package.swift target paths
match actual file locations), LICENSE verified correct by direct file
inspection (line count, header, footer).

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
3. Has Phase 1 actually been confirmed to build and run on real Apple
   Silicon hardware yet? (As of this writing: not yet confirmed — see
   Section 16.)

**Do not silently guess answers to important open questions.**

---

## 10. PENDING WORK

### Priority 1 — Critical

- [ ] Verify Phase 1 builds and runs on real Apple Silicon hardware
      (`swift build`, `swift test`, `swift run`), or confirm via a green
      CI run, and update Section 16 accordingly.

### Priority 2 — Important

- [ ] Begin Phase 2: `GeometryKit` (STL/OBJ import and validation).
- [ ] Resolve open questions 1–2 above (repo location, security contact).

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

# 12. SESSION CHECKPOINT

**Last completed action:**
`LICENSE` copied into place from a user-provided file and verified
correct (674 lines, correct header/footer). `PROJECT_STATE.md` (this
file) written.

**Current state:**
The `LibreTunnel/` repository scaffold is structurally complete for
Phase 1: app shell, `AppCore` module with tests, all governance/ADR/
documentation files, CI workflow, issue/PR templates, and a correct
`LICENSE`. Nothing in it has been compiled, run, or tested yet, because
the authoring environment has no Swift toolchain and is not macOS.

**Current problem:**
None blocking delivery. The one open technical risk is that Phase 1 has
never actually been built — Checkpoints 1 and 2 are not yet verified in
fact, only in intent. This is disclosed, not hidden.

**Next exact action:**
1. Zip the repository and deliver it to the project owner.
2. Project owner (or the next session, once a real macOS environment is
   available) runs `swift build && swift test && swift run` and reports
   the result — pass or fail — so Section 16 can be updated with real
   data instead of "NOT TESTED."
3. Once Checkpoints 1–2 are confirmed, proceed to Phase 2 (`GeometryKit`
   — STL/OBJ import and validation).

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
2026-09-06

**Build:**
NOT TESTED — no Swift toolchain or macOS environment was available in
the sandbox this scaffold was authored in. This is disclosed
deliberately rather than assumed away; see Section 11 journal and
`Documentation/developer-setup.md` for the same caveat in context.

**Tests:**
NOT TESTED — `AppCoreTests` is written but has not been executed.

**Application launches:**
NOT TESTED

**Major functionality verified:**
None yet — Phase 1 provides navigation/placeholder UI only, and even
that has not been run.

**Known issues:**
See Section 5, "Known limitations," and Section 9, "Open questions."

**Ready for another AI agent to continue:**
YES — with the explicit condition that the next step (by an AI, the
project owner, or both) should be running `swift build && swift test &&
swift run` on real Apple Silicon hardware and recording the actual
result here, rather than assuming Phase 1 works because it reads
correctly.
