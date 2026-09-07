// SPDX-License-Identifier: GPL-3.0-or-later
//
// LibreTunnel — an open-source, native macOS virtual wind tunnel and CFD
// front end for OpenFOAM.
// Copyright (C) 2026 The LibreTunnel Contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version. See LICENSE for the full text.

import simd

/// Builds a deduplicated `TriangleMesh` from a flat list of raw
/// triangles (each with its own three vertex positions, as every
/// supported file format natively stores them).
///
/// Shared by every importer — see
/// `Documentation/adr/0005-geometry-representation.md` for why
/// deduplication happens once, here, rather than in each importer or
/// each downstream consumer.
enum IndexedMeshBuilder {
    struct RawTriangle {
        let normal: SIMD3<Float>
        let v0: SIMD3<Float>
        let v1: SIMD3<Float>
        let v2: SIMD3<Float>
    }

    static func build(from rawTriangles: [RawTriangle]) -> TriangleMesh {
        var vertices: [SIMD3<Float>] = []
        var indexLookup: [VertexKey: Int32] = [:]
        var triangles: [TriangleMesh.IndexTriangle] = []
        var faceNormals: [SIMD3<Float>] = []
        triangles.reserveCapacity(rawTriangles.count)
        faceNormals.reserveCapacity(rawTriangles.count)

        func index(for vertex: SIMD3<Float>) -> Int32 {
            let key = VertexKey(vertex)
            if let existing = indexLookup[key] {
                return existing
            }
            let newIndex = Int32(vertices.count)
            vertices.append(vertex)
            indexLookup[key] = newIndex
            return newIndex
        }

        for triangle in rawTriangles {
            let a = index(for: triangle.v0)
            let b = index(for: triangle.v1)
            let c = index(for: triangle.v2)
            triangles.append(.init(a: a, b: b, c: c))
            faceNormals.append(triangle.normal)
        }

        return TriangleMesh(vertices: vertices, triangles: triangles, faceNormals: faceNormals)
    }

    /// Quantizes a vertex position to a fixed-precision grid so vertices
    /// that are the same point but differ only by floating-point noise
    /// are merged into one shared vertex. The precision (1e-5 of a
    /// model unit) is a deliberate, documented parameter — see
    /// ADR-0005 — not a hidden magic number.
    private struct VertexKey: Hashable {
        let x: Int64
        let y: Int64
        let z: Int64

        init(_ v: SIMD3<Float>) {
            let scale: Float = 100_000 // 1e-5 precision
            x = Int64((v.x * scale).rounded())
            y = Int64((v.y * scale).rounded())
            z = Int64((v.z * scale).rounded())
        }
    }
}
