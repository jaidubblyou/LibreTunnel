# ADR-0001: Project License

**Status:** Accepted
**Date:** 2026-09-06

## Context

LibreTunnel orchestrates OpenFOAM (GPL-3.0) as an external subprocess rather
than linking against it (see ADR-0002), so the project is not *legally*
required to adopt any particular license for that reason alone. A license
still had to be chosen deliberately, weighing:

- The project's explicit goal of maximum, durable openness — this is a
  community tool built partly in contrast to closed proprietary wind-tunnel
  software.
- Ease of contribution and adoption.
- Consistency with the license of the CFD ecosystem this project sits in
  (OpenFOAM itself, cfMesh, and most prior open-source OpenFOAM front ends
  such as HELYX-OS and FreeCAD's CfdOF workbench, are all GPL).
- The realistic risk, given this project's own stated motivation, that a
  permissively-licensed fork could be taken closed-source by a third party
  and never contributed back.

## Decision

LibreTunnel is licensed under the **GNU General Public License v3.0 or
later (GPL-3.0-or-later)**.

Every source file carries an SPDX identifier and a short license header
(see any file under `Sources/` for the exact wording). The full license
text is in `LICENSE`, reproduced verbatim from the Free Software
Foundation as required by the license itself.

## Alternatives considered

- **Apache-2.0** — permissive, explicit patent grant, maximizes
  adoption/contribution breadth, but permits closed-source derivatives with
  no obligation to contribute back. Rejected as inconsistent with "as open
  as we can."
- **MIT** — similar trade-offs to Apache-2.0 without the explicit patent
  grant. Rejected for the same reason.
- **AGPL-3.0** — considered briefly because it's the "maximally open"
  option in the GNU family, but its distinguishing clause only matters for
  software served over a network. LibreTunnel is a local desktop
  application; AGPL would add obligations with no practical effect here, so
  plain GPL-3.0-or-later was preferred for simplicity.

## Consequences

- Any distributed derivative of LibreTunnel (including a closed commercial
  fork) must also be released under GPL-3.0-or-later, or a
  GPL-3.0-compatible license.
- All future dependencies must be checked for GPL-3.0 compatibility before
  adoption (tracked in `Documentation/licensing.md`).
- Contribution is accepted via Developer Certificate of Origin (DCO)
  sign-off rather than a formal CLA, to keep the barrier to contribution
  low (see `CONTRIBUTING.md`).
- This is a legal/licensing judgment made with reasonable care, not a
  substitute for professional legal advice; if the project later enters
  commercial distribution or faces a licensing dispute, qualified legal
  counsel should be consulted.
