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

/// An indexed triangle mesh: a shared vertex array plus triangles that
/// reference it by index.
///
/// This is the shared representation every geometry importer (STL now,
/// OBJ in a later slice of Phase 2) produces — see
/// `Documentation/adr/0005-geometry-representation.md` for why an
/// indexed mesh was chosen over each format's native flat triangle
/// layout. Validation, repair, and rendering are all built against this
/// type, not against any particular file format.
public struct TriangleMesh: Equatable {
    /// Unique vertex positions, deduplicated at import time.
    public var vertices: [SIMD3<Float>]

    /// Triangles referencing `vertices` by index.
    public var triangles: [IndexTriangle]

    /// One face normal per triangle, in the same order as `triangles`.
    /// Sourced from the file where the format provides it (STL always
    /// does); later formats without face normals would need to compute
    /// them instead — not needed yet, so not implemented speculatively.
    public var faceNormals: [SIMD3<Float>]

    public init(vertices: [SIMD3<Float>], triangles: [IndexTriangle], faceNormals: [SIMD3<Float>]) {
        self.vertices = vertices
        self.triangles = triangles
        self.faceNormals = faceNormals
    }

    public struct IndexTriangle: Equatable {
        public var a: Int32
        public var b: Int32
        public var c: Int32

        public init(a: Int32, b: Int32, c: Int32) {
            self.a = a
            self.b = b
            self.c = c
        }
    }
}

public extension TriangleMesh {
    var vertexCount: Int { vertices.count }
    var triangleCount: Int { triangles.count }

    /// The axis-aligned bounding box of the mesh, or `nil` for an empty
    /// mesh. Used today for the Import stage's summary display; will
    /// also back the "unrealistic scale" geometry-validation check
    /// planned later in Phase 2.
    var boundingBox: (min: SIMD3<Float>, max: SIMD3<Float>)? {
        guard let first = vertices.first else { return nil }
        var minV = first
        var maxV = first
        for v in vertices.dropFirst() {
            minV = SIMD3<Float>(Swift.min(minV.x, v.x), Swift.min(minV.y, v.y), Swift.min(minV.z, v.z))
            maxV = SIMD3<Float>(Swift.max(maxV.x, v.x), Swift.max(maxV.y, v.y), Swift.max(maxV.z, v.z))
        }
        return (minV, maxV)
    }
}
