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

/// Imports STL files (both binary and ASCII variants) into a
/// `TriangleMesh`.
///
/// This is a synchronous, pure function on purpose — no threading or
/// SwiftUI concerns belong in `GeometryKit` (see `architecture.md`'s
/// layering). Callers that need to keep the UI responsive during import
/// of a large file (a real requirement — see the project's "low-end
/// hardware" principle) are responsible for dispatching the call off
/// the main thread, which the app's `ImportViewModel` does.
public enum STLImporter {
    public static func importMesh(from url: URL) throws -> TriangleMesh {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw STLImportError.unreadableFile(error.localizedDescription)
        }
        return try importMesh(from: data)
    }

    public static func importMesh(from data: Data) throws -> TriangleMesh {
        let bytes = [UInt8](data)
        if isLikelyBinary(bytes) {
            return try parseBinary(bytes)
        }
        guard let text = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
            throw STLImportError.unreadableFile("The file is not valid binary STL, and could not be decoded as text either.")
        }
        return try parseASCII(text)
    }

    // MARK: - Binary/ASCII disambiguation

    /// STL has a well-known ambiguity: a binary STL file's 80-byte
    /// header is arbitrary text, and many tools write "solid ..." into
    /// it out of habit — the same keyword that starts a genuine ASCII
    /// file. Checking for the "solid" prefix alone is therefore not
    /// reliable. The robust approach (used by other STL parsers for the
    /// same reason): if the file doesn't start with "solid" at all, it
    /// is definitely binary. If it does, disambiguate using the binary
    /// format's exact size formula (`84 + 50 * triangleCount`) — if the
    /// declared triangle count matches the actual file size precisely,
    /// treat it as binary; otherwise, ASCII.
    static func isLikelyBinary(_ bytes: [UInt8]) -> Bool {
        let looksLikeASCIIKeyword = bytes.count >= 5 && bytes.prefix(5).elementsEqual(Array("solid".utf8))
        if !looksLikeASCIIKeyword {
            return true // Doesn't start with "solid" at all — definitely binary, regardless of length.
        }
        // Starts with "solid": could be a genuine ASCII file, or a binary
        // file whose 80-byte header text happens to start with "solid".
        // A valid binary STL requires at least 84 bytes (header + triangle
        // count) to exist at all, so a shorter file that starts with
        // "solid" cannot be binary — it must be a (possibly tiny, possibly
        // empty) ASCII file. Checking length before the "solid" prefix, as
        // an earlier version of this function did, misclassified short
        // valid ASCII files as binary; this order fixes that.
        guard bytes.count >= 84 else { return false }
        let declaredCount = Int(readUInt32LE(bytes, at: 80))
        let expectedByteCount = 84 + declaredCount * 50
        return expectedByteCount == bytes.count
    }

    // MARK: - Binary parsing

    static func parseBinary(_ bytes: [UInt8]) throws -> TriangleMesh {
        guard bytes.count >= 84 else {
            throw STLImportError.truncatedBinaryHeader
        }
        let declaredCount = Int(readUInt32LE(bytes, at: 80))
        let expectedByteCount = 84 + declaredCount * 50
        guard expectedByteCount == bytes.count else {
            throw STLImportError.triangleCountMismatch(
                declared: declaredCount,
                expectedBytes: expectedByteCount,
                actualBytes: bytes.count
            )
        }

        var rawTriangles: [IndexedMeshBuilder.RawTriangle] = []
        rawTriangles.reserveCapacity(declaredCount)

        var offset = 84
        for _ in 0..<declaredCount {
            let normal = readVec3LE(bytes, at: offset)
            let v0 = readVec3LE(bytes, at: offset + 12)
            let v1 = readVec3LE(bytes, at: offset + 24)
            let v2 = readVec3LE(bytes, at: offset + 36)
            rawTriangles.append(.init(normal: normal, v0: v0, v1: v1, v2: v2))
            offset += 50 // 12 (normal) + 36 (3 vertices) + 2 (attribute byte count, ignored)
        }

        return IndexedMeshBuilder.build(from: rawTriangles)
    }

    private static func readUInt32LE(_ bytes: [UInt8], at offset: Int) -> UInt32 {
        UInt32(bytes[offset])
            | (UInt32(bytes[offset + 1]) << 8)
            | (UInt32(bytes[offset + 2]) << 16)
            | (UInt32(bytes[offset + 3]) << 24)
    }

    private static func readFloat32LE(_ bytes: [UInt8], at offset: Int) -> Float {
        Float(bitPattern: readUInt32LE(bytes, at: offset))
    }

    private static func readVec3LE(_ bytes: [UInt8], at offset: Int) -> SIMD3<Float> {
        SIMD3<Float>(
            readFloat32LE(bytes, at: offset),
            readFloat32LE(bytes, at: offset + 4),
            readFloat32LE(bytes, at: offset + 8)
        )
    }

    // MARK: - ASCII parsing

    static func parseASCII(_ text: String) throws -> TriangleMesh {
        var rawTriangles: [IndexedMeshBuilder.RawTriangle] = []
        var currentNormal: SIMD3<Float>?
        var pendingVertices: [SIMD3<Float>] = []

        let lines = text.split(whereSeparator: \.isNewline)
        for (offset, rawLine) in lines.enumerated() {
            let lineNumber = offset + 1
            let tokens = rawLine.split(whereSeparator: { $0 == " " || $0 == "\t" }).map(String.init)
            guard let keyword = tokens.first else { continue }

            switch keyword {
            case "facet":
                guard tokens.count == 5, tokens[1] == "normal" else {
                    throw STLImportError.malformedASCII(line: lineNumber, message: "Expected 'facet normal nx ny nz'.")
                }
                guard let nx = Float(tokens[2]), let ny = Float(tokens[3]), let nz = Float(tokens[4]) else {
                    throw STLImportError.malformedASCII(line: lineNumber, message: "Could not parse the facet normal's numbers.")
                }
                currentNormal = SIMD3<Float>(nx, ny, nz)
                pendingVertices = []

            case "vertex":
                guard tokens.count == 4 else {
                    throw STLImportError.malformedASCII(line: lineNumber, message: "Expected 'vertex x y z'.")
                }
                guard let x = Float(tokens[1]), let y = Float(tokens[2]), let z = Float(tokens[3]) else {
                    throw STLImportError.malformedASCII(line: lineNumber, message: "Could not parse the vertex's numbers.")
                }
                pendingVertices.append(SIMD3<Float>(x, y, z))

            case "endfacet":
                guard let normal = currentNormal, pendingVertices.count == 3 else {
                    throw STLImportError.malformedASCII(line: lineNumber, message: "'endfacet' reached without a normal and exactly three vertices.")
                }
                rawTriangles.append(.init(normal: normal, v0: pendingVertices[0], v1: pendingVertices[1], v2: pendingVertices[2]))
                currentNormal = nil
                pendingVertices = []

            default:
                continue // "solid", "endsolid", "outer loop", "endloop" — structural only
            }
        }

        guard !rawTriangles.isEmpty else {
            throw STLImportError.emptyFile
        }

        return IndexedMeshBuilder.build(from: rawTriangles)
    }
}
