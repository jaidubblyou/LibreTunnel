# Contributing to LibreTunnel

Thanks for considering contributing. This project deliberately spans
several skill sets (SwiftUI, Metal graphics, geometry processing, OpenFOAM
and CFD) — you don't need all of them to help. See the module map below to
find something that matches what you know.

## Before you start

1. Read `PROJECT_STATE.md` — it's the source of truth for current status,
   in-progress work, and known problems. Don't assume the conversation
   history or your own memory of the project is complete; the repository
   and this file take precedence.
2. Skim `Documentation/architecture.md` and the ADRs in
   `Documentation/adr/` — several core decisions (license, OpenFOAM
   runtime strategy, platform scope, code signing) are already made and
   documented with their reasoning. Please don't silently re-open them;
   if you think one is wrong, open an issue and make the case.
3. Check open issues before starting significant work, to avoid duplicate
   effort.

## The one rule that isn't optional

**LibreTunnel never links against OpenFOAM libraries.** OpenFOAM is
invoked only as an external subprocess (`blockMesh`, `snappyHexMesh`,
`simpleFoam`, etc.), communicating via the filesystem and process
stdout/stderr. This is documented in `Documentation/adr/0002` and is a
licensing-relevant architectural boundary, not just a style preference.
If a change would require linking against an OpenFOAM library, it needs a
new ADR and explicit discussion first, not a pull request.

## Module map

See the table in `Documentation/architecture.md`. Each module is (or will
be) an independent Swift package target with its own tests.

## Development setup

See `Documentation/developer-setup.md`.

## Sign off your commits (DCO)

We use the Developer Certificate of Origin instead of a CLA, to keep the
contribution barrier low. Add `-s` when committing:

```bash
git commit -s -m "Your commit message"
```

This adds a `Signed-off-by` line certifying you have the right to submit
the change under the project's license (GPL-3.0-or-later).

## Code style

- Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- Every new source file gets the standard SPDX header — copy it from any
  existing file under `Sources/`.
- Prefer the simplest design that solves the problem at hand and remains
  testable. Don't add abstraction layers "for later" — see the project's
  "prefer simple, explicit design" principle.

## Tests

- New logic needs tests. `swift test` must pass before a PR is opened.
- If you're touching `GeometryKit`, `CaseKit`, or anything that will
  eventually talk to OpenFOAM, prefer testing against OpenFOAM's own
  `motorBike` tutorial case where relevant, rather than inventing new test
  geometry — see `Documentation/testing.md`.

## Documenting decisions

If your change affects architecture, licensing, the OpenFOAM
integration boundary, the project format, or anything else that future
contributors would need to know the *reasoning* behind (not just the
code), add or update an ADR in `Documentation/adr/`. Use the existing
ADRs as a template.

## Keeping `PROJECT_STATE.md` current

If you're an AI agent (or a human!) making a meaningful change —
implementing something, fixing a bug, making an architectural decision,
discovering a problem — add an entry to the Development Journal in
`PROJECT_STATE.md` and update the Session Checkpoint section before you
stop working. This is how the project stays understandable to the next
contributor, human or AI, who picks it up without live access to this
conversation.

## Reporting bugs / requesting features

Use the issue templates under `.github/ISSUE_TEMPLATE/`. There's a
dedicated template for CFD/technical issues (mesh quality, convergence,
OpenFOAM version compatibility) separate from general app bugs.

## Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md).
