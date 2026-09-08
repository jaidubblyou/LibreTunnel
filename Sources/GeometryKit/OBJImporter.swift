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

import Foundation
import simd

/// Imports Wavefront OBJ files into a `TriangleMesh`.
///
/// Like `STLImporter`, this is a synchronous, pure function with no UI
/// or threading concerns — see that type's documentation for why.
///
/// Two deliberate, documented simplifications (see
/// `Documentation/adr/0005-geometry-representation.md`'s amendment for
/// the full reasoning, not just the summary here):
///
/// 1. **Face normals are always computed geometrically** from the
///    triangle's vertex positions, never read from the file's `vn`
///    data. `TriangleMesh.faceNormals` means the same thing regardless
///    of which importer produced it — the true geometric normal, which
///    is also what geometry *validation* (a later slice of this phase)
///    actually needs, as opposed to an author's stylized shading
///    normal.
/// 2. **Faces with more than 3 vertices are fan-triangulated** from
///    their first vertex. This is correct for convex, planar polygons
///    (the overwhelming majority of CAD-exported geometry) but can
///    produce wrong triangles for non-convex (concave) polygon faces.
///    Not handled today; revisit if real imported geometry shows this
///    matters in practice.
public enum OBJImporter {
    public static func importMesh(from url: URL) throws -> TriangleMesh {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw OBJImportError.unreadableFile(error.localizedDescription)
        }
        guard let text = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
            throw OBJImportError.unreadableFile("The file could not be decoded as text.")
        }
        return try importMesh(from: text)
    }

    public static func importMesh(from text: String) throws -> TriangleMesh {
        var positions: [SIMD3<Float>] = []
        var rawTriangles: [IndexedMeshBuilder.RawTriangle] = []

        let lines = text.split(whereSeparator: \.isNewline)
        for (offset, rawLine) in lines.enumerated() {
            let lineNumber = offset + 1
            let tokens = rawLine.split(whereSeparator: { $0 == " " || $0 == "\t" }).map(String.init)
            guard let keyword = tokens.first else { continue }

            switch keyword {
            case "v":
                guard tokens.count >= 4,
                      let x = Float(tokens[1]), let y = Float(tokens[2]), let z = Float(tokens[3]) else {
                    throw OBJImportError.malformedVertex(line: lineNumber, message: "Expected 'v x y z'.")
                }
                positions.append(SIMD3<Float>(x, y, z))

            case "f":
                let faceIndices = try parseFaceIndices(
                    tokens: tokens.dropFirst(),
                    currentVertexCount: positions.count,
                    lineNumber: lineNumber
                )
                // Fan-triangulate: (0,1,2), (0,2,3), (0,3,4), ...
                for i in 1..<(faceIndices.count - 1) {
                    let a = positions[faceIndices[0]]
                    let b = positions[faceIndices[i]]
                    let c = positions[faceIndices[i + 1]]
                    rawTriangles.append(.init(normal: geometricNormal(a, b, c), v0: a, v1: b, v2: c))
                }

            default:
                continue // vt, vn, vp, o, g, s, mtllib, usemtl, comments — not needed for import
            }
        }

        guard !rawTriangles.isEmpty else {
            throw OBJImportError.emptyFile
        }

        return IndexedMeshBuilder.build(from: rawTriangles)
    }

    /// Parses a face's vertex references (e.g. `1`, `1/2`, `1/2/3`, or
    /// `1//3`) into resolved, zero-based position indices, handling
    /// OBJ's 1-based indexing and negative (relative-to-current-count)
    /// indexing.
    private static func parseFaceIndices(
        tokens: some Sequence<String>,
        currentVertexCount: Int,
        lineNumber: Int
    ) throws -> [Int] {
        var faceIndices: [Int] = []
        for token in tokens {
            let positionComponent = token.split(separator: "/", omittingEmptySubsequences: false).first.map(String.init) ?? token
            guard let rawIndex = Int(positionComponent) else {
                throw OBJImportError.malformedFace(line: lineNumber, message: "Could not parse a vertex index in this face.")
            }
            let resolvedIndex: Int
            switch rawIndex {
            case let i where i > 0:
                resolvedIndex = i - 1 // OBJ indices are 1-based
            case let i where i < 0:
                resolvedIndex = currentVertexCount + i // relative to vertices defined so far
            default:
                throw OBJImportError.malformedFace(line: lineNumber, message: "Vertex index 0 is not valid in OBJ — indices are 1-based.")
            }
            guard resolvedIndex >= 0 && resolvedIndex < currentVertexCount else {
                throw OBJImportError.faceIndexOutOfRange(line: lineNumber, index: rawIndex, vertexCount: currentVertexCount)
            }
            faceIndices.append(resolvedIndex)
        }
        guard faceIndices.count >= 3 else {
            throw OBJImportError.malformedFace(line: lineNumber, message: "A face needs at least 3 vertices.")
        }
        return faceIndices
    }

    private static func geometricNormal(_ a: SIMD3<Float>, _ b: SIMD3<Float>, _ c: SIMD3<Float>) -> SIMD3<Float> {
        let cross = simd_cross(b - a, c - a)
        let length = simd_length(cross)
        guard length > 0 else { return SIMD3<Float>(0, 0, 0) } // degenerate triangle; leave as zero rather than divide by zero
        return cross / length
    }
}
