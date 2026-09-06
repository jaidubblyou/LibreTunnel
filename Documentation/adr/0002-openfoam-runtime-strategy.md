# ADR-0002: OpenFOAM Distribution, Integration Boundary, and Runtime Provisioning

**Status:** Accepted
**Date:** 2026-09-06

## Context

OpenFOAM has two independent distributions with materially different macOS
support:

- **OpenFOAM Foundation** (openfoam.org): on macOS, installed via Canonical
  Multipass, which runs an Ubuntu VM. No native macOS compilation path.
- **OpenCFD / ESI OpenFOAM** (openfoam.com): has a proven native macOS
  compilation path, demonstrated by the actively-maintained open-source
  project `gerlero/openfoam-app` (GPL-3.0), which works around macOS's
  case-insensitive default filesystem by mounting OpenFOAM from a
  read-only, case-sensitive disk image — no VM, no emulation.

On an 8 GB Apple Silicon Mac, VM overhead is a real cost we cannot absorb
casually; a benchmark comparing native ARM compilation to an emulated
Docker environment showed roughly a 13x difference in tutorial run time.
Separately, `gerlero/openfoam-app` dropped Intel Mac support as of its
v2.2.0 release (2026), reinforcing an Apple-Silicon-only scope for a new
project starting today (see ADR on platform scope, folded into this
decision record set via the project's session history).

OPENFOAM® and OpenCFD® are registered trademarks of OpenCFD Limited; any
project building on OpenFOAM must not imply endorsement.

## Decision

1. **Distribution:** target OpenCFD's OpenFOAM (openfoam.com), latest
   stable release at time of each LibreTunnel release, because it is the
   only distribution with a genuine native macOS path.

2. **Integration boundary (hard architectural rule):** LibreTunnel invokes
   OpenFOAM **only** as an external subprocess — launching `blockMesh`,
   `snappyHexMesh`, `simpleFoam`, etc. as separate processes and
   communicating exclusively via the filesystem (the OpenFOAM case
   directory) and process stdout/stderr. **No LibreTunnel code may link
   against `libOpenFOAM`, `libfiniteVolume`, or any other OpenFOAM library.**
   This is enforced by module boundary (only `OpenFOAMRuntime` and
   `SolverBridge` know OpenFOAM exists at all) and must be treated as a
   standing constraint in code review, not just a one-time decision — see
   ADR-0001 for why this boundary matters even though it isn't the only
   reason for our license choice.

3. **Runtime provisioning (v1):** LibreTunnel detects an existing native
   OpenCFD install; if absent, it drives installation itself via Homebrew,
   using `--no-quarantine` on the install command so the provisioned
   OpenFOAM binaries do not trigger a second Gatekeeper prompt beyond the
   one already required for LibreTunnel.app itself (ADR-0004). This is
   driven from a visible, real-progress UI — never a bare terminal — per
   the process-supervision policy in ADR-0003. We maintain our own
   Homebrew tap/build recipe (adapted from, and crediting, the technique
   proven by `gerlero/openfoam-app`) rather than depending on a third
   party's tap indefinitely, to avoid an unbounded single-maintainer bus
   factor for a component this central.

4. **Deferred to a later phase, not abandoned:** a fully bundled, signed
   OpenFOAM runtime shipped inside LibreTunnel itself (removing the
   Homebrew install step entirely) is a real UX improvement and a planned
   roadmap item, but is deliberately sequenced after the core product
   (geometry, meshing, case generation, results visualisation) is proven —
   see `architecture.md`, Phase 5 vs. later phases.

## Alternatives considered

- **OpenFOAM Foundation + Multipass** — officially supported, easiest to
  stay in sync with upstream, but VM overhead is a poor fit for the 8 GB
  target and adds a second heavyweight system dependency (Multipass
  itself) beyond Homebrew.
- **Docker Desktop** — has ARM images now, but is slower than a native
  compile (per the benchmark above), and Docker Desktop's licensing terms
  for larger organisations add a complication we don't need to take on for
  no performance benefit.
- **Fully bundled runtime from day one** — best possible end-user
  experience, but a substantial standalone engineering effort (build
  pipeline, signing, notarization-adjacent packaging, multi-GB artifact
  hosting) that would delay validating the actual product. Rejected for
  v1, retained on the roadmap.
- **Require manual OpenFOAM installation** — simplest for us, but directly
  violates the "no command line" requirement. Rejected.

## Consequences

- LibreTunnel's first-run experience includes an OpenFOAM install step,
  automated and progress-visible, but not instantaneous (compiling/
  installing OpenFOAM takes real time on first run).
- The project takes on maintenance of a Homebrew tap/build recipe tracking
  OpenCFD's roughly twice-yearly release cadence.
- Every README, release note, and in-app "About" screen must carry a
  trademark disclaimer: LibreTunnel is not affiliated with or endorsed by
  OpenCFD Limited or the OpenFOAM Foundation.
- The subprocess-only boundary must be called out explicitly in
  `CONTRIBUTING.md` so future contributors don't "optimise" it away by
  linking directly against OpenFOAM libraries.
