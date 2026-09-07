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

import XCTest
@testable import GeometryKit

final class STLImporterTests: XCTestCase {
    private let singleTriangle = STLFixtures.Triangle(
        normal: (0, 0, 1),
        v0: (0, 0, 0),
        v1: (1, 0, 0),
        v2: (0, 1, 0)
    )

    // Two triangles sharing an edge — (0,0,0) and (1,1,0) each appear in
    // both — so a correct importer should produce 4 unique vertices,
    // not 6.
    private var sharedEdgeQuad: [STLFixtures.Triangle] {
        [
            .init(normal: (0, 0, 1), v0: (0, 0, 0), v1: (1, 0, 0), v2: (1, 1, 0)),
            .init(normal: (0, 0, 1), v0: (0, 0, 0), v1: (1, 1, 0), v2: (0, 1, 0))
        ]
    }

    // MARK: - Binary

    func testParsesBinarySingleTriangle() throws {
        let data = STLFixtures.binarySTL(triangles: [singleTriangle])
        let mesh = try STLImporter.importMesh(from: data)

        XCTAssertEqual(mesh.triangleCount, 1)
        XCTAssertEqual(mesh.vertexCount, 3)
        XCTAssertEqual(mesh.faceNormals.first, SIMD3<Float>(0, 0, 1))
    }

    func testBinaryDeduplicatesSharedVertices() throws {
        let data = STLFixtures.binarySTL(triangles: sharedEdgeQuad)
        let mesh = try STLImporter.importMesh(from: data)

        XCTAssertEqual(mesh.triangleCount, 2)
        XCTAssertEqual(mesh.vertexCount, 4, "Expected the two shared vertices to be merged, not duplicated")
    }

    func testDetectsBinaryDespiteSolidPrefixInHeader() throws {
        // Real-world gotcha: some binary STL files have "solid ..." as
        // arbitrary text in their 80-byte header, which must not be
        // misread as the start of an ASCII file.
        let data = STLFixtures.binarySTL(header: "solid exported by ToolXYZ", triangles: [singleTriangle])
        let mesh = try STLImporter.importMesh(from: data)

        XCTAssertEqual(mesh.triangleCount, 1)
    }

    func testThrowsOnTruncatedBinaryHeader() {
        let data = Data(repeating: 0, count: 10) // far short of the 84-byte minimum
        XCTAssertThrowsError(try STLImporter.importMesh(from: data)) { error in
            XCTAssertEqual(error as? STLImportError, .truncatedBinaryHeader)
        }
    }

    func testThrowsOnBinaryTriangleCountMismatch() {
        var data = STLFixtures.binarySTL(triangles: [singleTriangle])
        data.append(contentsOf: [0, 0, 0]) // corrupt: extra trailing bytes
        XCTAssertThrowsError(try STLImporter.importMesh(from: data)) { error in
            guard case .triangleCountMismatch(let declared, _, let actualBytes) = error as? STLImportError else {
                return XCTFail("Expected .triangleCountMismatch, got \(error)")
            }
            XCTAssertEqual(declared, 1)
            XCTAssertEqual(actualBytes, 84 + 50 + 3)
        }
    }

    // MARK: - ASCII

    func testParsesASCIISingleTriangle() throws {
        let text = STLFixtures.asciiSTL(triangles: [singleTriangle])
        let mesh = try STLImporter.importMesh(from: Data(text.utf8))

        XCTAssertEqual(mesh.triangleCount, 1)
        XCTAssertEqual(mesh.vertexCount, 3)
        XCTAssertEqual(mesh.faceNormals.first, SIMD3<Float>(0, 0, 1))
    }

    func testASCIIDeduplicatesSharedVertices() throws {
        let text = STLFixtures.asciiSTL(triangles: sharedEdgeQuad)
        let mesh = try STLImporter.importMesh(from: Data(text.utf8))

        XCTAssertEqual(mesh.triangleCount, 2)
        XCTAssertEqual(mesh.vertexCount, 4)
    }

    func testThrowsOnEmptyASCIIFile() {
        let text = "solid empty\nendsolid empty"
        XCTAssertThrowsError(try STLImporter.importMesh(from: Data(text.utf8))) { error in
            XCTAssertEqual(error as? STLImportError, .emptyFile)
        }
    }

    func testThrowsOnMalformedASCIIVertexLine() {
        let text = """
        solid broken
          facet normal 0 0 1
            outer loop
              vertex 0 0 0
              vertex 1 0
              vertex 0 1 0
            endloop
          endfacet
        endsolid broken
        """
        XCTAssertThrowsError(try STLImporter.importMesh(from: Data(text.utf8))) { error in
            guard case .malformedASCII = error as? STLImportError else {
                return XCTFail("Expected .malformedASCII, got \(error)")
            }
        }
    }

    // MARK: - Derived properties

    func testBoundingBox() throws {
        let data = STLFixtures.binarySTL(triangles: [singleTriangle])
        let mesh = try STLImporter.importMesh(from: data)
        let box = try XCTUnwrap(mesh.boundingBox)

        XCTAssertEqual(box.min, SIMD3<Float>(0, 0, 0))
        XCTAssertEqual(box.max, SIMD3<Float>(1, 1, 0))
    }
}
