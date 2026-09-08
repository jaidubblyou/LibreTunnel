# ADR-0005: Geometry Representation and Parser Strategy

**Status:** Accepted
**Date:** 2026-09-06

## Context

`GeometryKit` needs an internal representation for imported 3D geometry
that later modules (`DomainKit`, validation/repair logic, `RenderKit`,
eventually `CaseKit`) can all build on. Two decisions were needed before
writing an STL importer:

1. Whether to depend on a third-party geometry/mesh library or hand-roll
   parsing and the data model.
2. What in-memory shape the mesh takes — specifically, whether to keep
   the flat "triangle soup" that STL natively stores (each triangle with
   its own three vertex copies, no sharing) or convert to an indexed
   mesh (a shared vertex list plus triangles referencing it by index).

This matters beyond STL: manifoldness checks, hole detection, and
disconnected-component detection (all required by Phase 2's validation
step, and listed as core functional requirements) depend on knowing
which triangles share an edge or vertex. That's not answerable from flat
triangle soup without redoing the work every time — it requires shared,
indexed vertices.

## Decision

1. **No third-party geometry library for import/representation.** STL
   and OBJ are simple, fully open, well-documented formats. A hand-
   rolled parser gives full control over the validation and repair
   logic Phase 2 also needs, avoids a new GPL-compatibility check, and
   keeps the dependency count at zero. Revisit only if a later phase
   (e.g. robust boolean operations for repair) hits a problem a hand-
   rolled implementation genuinely can't solve well.

2. **Internal representation is an indexed triangle mesh**
   (`GeometryKit.TriangleMesh`: a shared vertex array plus triangles
   referencing it by index), not flat triangle soup. Importers (STL now,
   OBJ later) parse the source format's native shape, then build the
   indexed mesh by deduplicating vertices that are the same point within
   a fixed tolerance (1e-5 of a model unit) — common in STL files
   exported by different tools, which frequently emit the same shared
   vertex as slightly different floating-point values per triangle.

## Alternatives considered

- **Adopt a third-party mesh library** (e.g. a computational-geometry
  package) — would speed up validation/repair logic later, but adds a
  dependency to re-evaluate for GPL-3.0 compatibility and Apple Silicon
  support, for formats simple enough not to need it. Rejected for now,
  per the project's "minimise unnecessary dependencies" principle.
- **Keep flat triangle soup, matching STL's native format exactly** —
  simplest possible importer, but pushes the deduplication problem into
  every later consumer (validation, rendering) instead of solving it
  once at import time. Rejected.

## Consequences

- Every importer (STL now, OBJ in the next slice of Phase 2) must
  produce a `TriangleMesh`, not a format-specific structure — this is
  the shared contract the rest of `GeometryKit` and later modules build
  on.
- The 1e-5 deduplication tolerance is a real, documented parameter, not
  a hidden magic number — it directly affects whether legitimately
  close-but-distinct vertices get incorrectly merged. Revisit if real
  imported geometry shows this is too tight or too loose.
- Because deduplication happens at import time, per-vertex data that
  genuinely varies at "the same" position (e.g., hard-edge normals) is
  not preserved. STL provides only a face normal, so this isn't a
  regression here, but it's a constraint worth remembering if OBJ import
  (which can carry per-vertex normals) needs to represent hard edges
  later.

## Amendment (Phase 2, slice 2 — OBJ import)

OBJ's native format is already indexed (a `v` list plus `f` lines
referencing it by index), unlike STL's flat triangle soup. Two
decisions made when implementing `OBJImporter`, extending this ADR
rather than superseding it:

1. **`OBJImporter` still routes through the same `IndexedMeshBuilder`
   dedup pass as `STLImporter`**, even though OBJ is already indexed.
   This keeps vertex-welding behavior uniform and robust regardless of
   how well a given exporter deduplicated its own output, and costs
   nothing extra given decision 2 below.
2. **`TriangleMesh.faceNormals` is always computed geometrically from
   vertex positions, for both formats** — OBJ's `vn` (per-vertex normal)
   data is parsed past but never used. This keeps "what does a face
   normal mean" consistent regardless of source format, and is also the
   *more correct* choice for this application's purposes: geometry
   *validation* (a later slice of this phase) needs the true geometric
   normal to detect things like inverted normals, not an author's
   stylized shading normal. Since per-vertex normal data is already
   being discarded, there's no cost to also discarding OBJ's
   position-splitting that exporters typically use only to support
   different `vn` values at "the same" position for hard-edge shading —
   decision 1's uniform dedup doesn't lose anything decision 2 wasn't
   already giving up.
3. **Polygon faces (more than 3 vertices) are fan-triangulated** from
   their first vertex, which is correct for convex, planar faces but
   not guaranteed correct for concave ones. Documented in
   `OBJImporter`'s own comments; not addressed with a more robust
   triangulation algorithm (e.g. ear clipping) unless real imported
   geometry shows it's needed — per "prefer simple, explicit design."
