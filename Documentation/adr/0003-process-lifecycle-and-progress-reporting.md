# ADR-0003: Process Lifecycle and Progress Reporting Policy

**Status:** Accepted
**Date:** 2026-09-06

## Context

LibreTunnel spawns external subprocesses for several long-running
operations: Homebrew-driven OpenFOAM installation, `blockMesh`,
`snappyHexMesh`, and `simpleFoam`. Left unmanaged, this creates real risks
specific to this project's constraints:

- On an 8 GB Apple Silicon machine, an orphaned or runaway subprocess left
  running after the user cancels a task, closes a window, or quits the app
  can consume memory and CPU the rest of the system needs.
- A user should never be "left wondering" whether a long operation is still
  running, stuck, or finished — especially for operations that can
  legitimately take minutes (a first-time OpenFOAM install; meshing or
  solving a non-trivial case).
- The project's "no fake functionality" principle rules out a smooth,
  fabricated progress animation for tools that don't actually expose
  structured progress (Homebrew installs are the clearest example).

## Decision

Introduce a shared component, **`ProcessSupervisor`** (living in
`AppCore`, used by both the future `OpenFOAMRuntime` and `SolverBridge`
modules), responsible for the full lifecycle of every subprocess
LibreTunnel spawns:

1. **Process-group tracking, not just PID tracking.** Every spawned
   process is placed in its own process group so that cancellation or app
   termination can kill the entire subprocess tree (including anything
   OpenFOAM's own shell scripts fork), not just the direct child.

2. **Guaranteed cleanup on app quit or crash.** Termination handlers ensure
   no subprocess outlives the app. Escalation is SIGTERM first, with a
   bounded timeout before SIGKILL.

3. **Progress is always sourced from real signal, per tool:**
   - `snappyHexMesh` has distinct, log-visible phases (castellation → snap
     → layers) → real step-based progress.
   - `simpleFoam` prints an iteration count each timestep → a real
     percentage against the configured iteration or convergence target.
     This is the same mechanism that will drive the live convergence view
     described in the project's UX requirements — it is not a separate
     feature to build later.
   - Homebrew installs expose no structured progress protocol → honest
     step labels plus a live log tail and elapsed time, never a fabricated
     percentage.

4. **Every task ends in an explicit terminal state** — success, failure, or
   user-cancellation — each surfaced via both a persistent in-app status
   and a local `UserNotifications` alert, so a user who has switched away
   from the app still finds out.

5. **Cancellation actually cancels.** The Cancel affordance in the UI must
   terminate the underlying subprocess tree, not merely hide its progress
   UI while it keeps running.

## Alternatives considered

- **Ad-hoc `Process` usage per call site** — simplest to write initially,
  but would duplicate lifecycle-safety logic across every subprocess call
  and make it easy for a future contributor to add a new long-running task
  that forgets cleanup or fakes progress. Rejected in favour of one shared,
  reviewed component.
- **Fabricated smooth progress bars for all tasks** — better-looking for
  Homebrew installs specifically, but directly violates the project's
  scientific-integrity and no-fake-functionality principles, which apply
  to UI honesty generally, not only to CFD results.

## Consequences

- `ProcessSupervisor` is now a required dependency for any future module
  that spawns a subprocess; it should be built and unit-tested (with a
  fake/mock subprocess) before `OpenFOAMRuntime` or `SolverBridge` land in
  their respective phases, not after.
- Log parsing for `snappyHexMesh` and `simpleFoam` progress is a real
  implementation task with its own edge cases (log format can vary
  slightly between OpenFOAM versions) — tracked as a known area needing
  careful testing against multiple OpenFOAM releases.
