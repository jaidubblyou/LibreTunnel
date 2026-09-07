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

/// Builds valid and deliberately-malformed binary STL byte content for
/// tests, so `STLImporterTests` doesn't depend on external fixture
/// files (which would need SwiftPM resource bundling — unnecessary
/// complexity for content this simple to generate directly).
enum STLFixtures {
    struct Triangle {
        let normal: (Float, Float, Float)
        let v0: (Float, Float, Float)
        let v1: (Float, Float, Float)
        let v2: (Float, Float, Float)
    }

    /// A valid binary STL file for the given triangles.
    static func binarySTL(header: String = "LibreTunnel test fixture", triangles: [Triangle]) -> Data {
        var data = Data()
        var headerBytes = Array(header.utf8.prefix(80))
        headerBytes.append(contentsOf: repeatElement(0, count: 80 - headerBytes.count))
        data.append(contentsOf: headerBytes)
        data.append(contentsOf: littleEndianBytes(UInt32(triangles.count)))
        for triangle in triangles {
            appendVec3(&data, triangle.normal)
            appendVec3(&data, triangle.v0)
            appendVec3(&data, triangle.v1)
            appendVec3(&data, triangle.v2)
            data.append(contentsOf: [0, 0]) // attribute byte count
        }
        return data
    }

    /// A single-triangle ASCII STL file.
    static func asciiSTL(triangles: [Triangle]) -> String {
        var lines = ["solid fixture"]
        for t in triangles {
            lines.append("  facet normal \(t.normal.0) \(t.normal.1) \(t.normal.2)")
            lines.append("    outer loop")
            lines.append("      vertex \(t.v0.0) \(t.v0.1) \(t.v0.2)")
            lines.append("      vertex \(t.v1.0) \(t.v1.1) \(t.v1.2)")
            lines.append("      vertex \(t.v2.0) \(t.v2.1) \(t.v2.2)")
            lines.append("    endloop")
            lines.append("  endfacet")
        }
        lines.append("endsolid fixture")
        return lines.joined(separator: "\n")
    }

    private static func littleEndianBytes(_ value: UInt32) -> [UInt8] {
        [
            UInt8(value & 0xFF),
            UInt8((value >> 8) & 0xFF),
            UInt8((value >> 16) & 0xFF),
            UInt8((value >> 24) & 0xFF)
        ]
    }

    private static func appendVec3(_ data: inout Data, _ v: (Float, Float, Float)) {
        data.append(contentsOf: littleEndianBytes(v.0.bitPattern))
        data.append(contentsOf: littleEndianBytes(v.1.bitPattern))
        data.append(contentsOf: littleEndianBytes(v.2.bitPattern))
    }
}
