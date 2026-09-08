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

final class OBJImporterTests: XCTestCase {
    func testParsesSingleTriangle() throws {
        let text = """
        v 0 0 0
        v 1 0 0
        v 0 1 0
        f 1 2 3
        """
        let mesh = try OBJImporter.importMesh(from: text)

        XCTAssertEqual(mesh.triangleCount, 1)
        XCTAssertEqual(mesh.vertexCount, 3)
    }

    func testFanTriangulatesQuadFace() throws {
        let text = """
        v 0 0 0
        v 1 0 0
        v 1 1 0
        v 0 1 0
        f 1 2 3 4
        """
        let mesh = try OBJImporter.importMesh(from: text)

        XCTAssertEqual(mesh.triangleCount, 2, "A 4-vertex face should fan-triangulate into 2 triangles")
        XCTAssertEqual(mesh.vertexCount, 4)
    }

    func testHandlesFaceVertexTextureNormalSyntax() throws {
        // v/vt/vn syntax — texture and normal indices should be parsed
        // and ignored, not break parsing.
        let text = """
        v 0 0 0
        v 1 0 0
        v 0 1 0
        vt 0 0
        vt 1 0
        vt 0 1
        vn 0 0 1
        f 1/1/1 2/2/1 3/3/1
        """
        let mesh = try OBJImporter.importMesh(from: text)

        XCTAssertEqual(mesh.triangleCount, 1)
        XCTAssertEqual(mesh.vertexCount, 3)
    }

    func testHandlesFaceVertexPositionNormalSyntaxWithNoTexture() throws {
        // v//vn syntax (no texture coordinate).
        let text = """
        v 0 0 0
        v 1 0 0
        v 0 1 0
        vn 0 0 1
        f 1//1 2//1 3//1
        """
        let mesh = try OBJImporter.importMesh(from: text)

        XCTAssertEqual(mesh.triangleCount, 1)
    }

    func testHandlesNegativeRelativeIndices() throws {
        let text = """
        v 0 0 0
        v 1 0 0
        v 0 1 0
        f -3 -2 -1
        """
        let mesh = try OBJImporter.importMesh(from: text)

        XCTAssertEqual(mesh.triangleCount, 1)
        XCTAssertEqual(mesh.vertexCount, 3)
    }

    func testIgnoresCommentsAndOtherKeywords() throws {
        let text = """
        # this is a comment
        mtllib scene.mtl
        o MyObject
        g group1
        v 0 0 0
        v 1 0 0
        v 0 1 0
        vn 0 0 1
        usemtl Material
        s 1
        f 1 2 3
        """
        let mesh = try OBJImporter.importMesh(from: text)

        XCTAssertEqual(mesh.triangleCount, 1)
        XCTAssertEqual(mesh.vertexCount, 3)
    }

    func testComputesGeometricNormalRatherThanFileNormal() throws {
        // The file claims a normal of (0, 1, 0), which is wrong for a
        // triangle in the XY plane — the correct geometric normal is
        // (0, 0, 1) or (0, 0, -1) depending on winding. The importer
        // must compute its own normal, not trust the file's `vn`.
        let text = """
        v 0 0 0
        v 1 0 0
        v 0 1 0
        vn 0 1 0
        f 1/1/1 2/1/1 3/1/1
        """
        let mesh = try OBJImporter.importMesh(from: text)
        let normal = try XCTUnwrap(mesh.faceNormals.first)

        XCTAssertEqual(abs(normal.z), 1, accuracy: 0.0001)
        XCTAssertEqual(normal.x, 0, accuracy: 0.0001)
        XCTAssertEqual(normal.y, 0, accuracy: 0.0001)
    }

    func testThrowsOnEmptyFile() {
        let text = "v 0 0 0\nv 1 0 0\nv 0 1 0\n" // vertices only, no faces
        XCTAssertThrowsError(try OBJImporter.importMesh(from: text)) { error in
            XCTAssertEqual(error as? OBJImportError, .emptyFile)
        }
    }

    func testThrowsOnMalformedVertexLine() {
        let text = "v 1 2\nf 1 1 1"
        XCTAssertThrowsError(try OBJImporter.importMesh(from: text)) { error in
            guard case .malformedVertex = error as? OBJImportError else {
                return XCTFail("Expected .malformedVertex, got \(error)")
            }
        }
    }

    func testThrowsOnFaceIndexOutOfRange() {
        let text = """
        v 0 0 0
        v 1 0 0
        v 0 1 0
        f 1 2 99
        """
        XCTAssertThrowsError(try OBJImporter.importMesh(from: text)) { error in
            guard case .faceIndexOutOfRange(_, let index, let vertexCount) = error as? OBJImportError else {
                return XCTFail("Expected .faceIndexOutOfRange, got \(error)")
            }
            XCTAssertEqual(index, 99)
            XCTAssertEqual(vertexCount, 3)
        }
    }

    func testThrowsOnZeroFaceIndex() {
        let text = """
        v 0 0 0
        v 1 0 0
        v 0 1 0
        f 0 1 2
        """
        XCTAssertThrowsError(try OBJImporter.importMesh(from: text)) { error in
            guard case .malformedFace = error as? OBJImportError else {
                return XCTFail("Expected .malformedFace, got \(error)")
            }
        }
    }

    func testThrowsOnFaceWithTooFewVertices() {
        let text = """
        v 0 0 0
        v 1 0 0
        f 1 2
        """
        XCTAssertThrowsError(try OBJImporter.importMesh(from: text)) { error in
            guard case .malformedFace = error as? OBJImportError else {
                return XCTFail("Expected .malformedFace, got \(error)")
            }
        }
    }
}
