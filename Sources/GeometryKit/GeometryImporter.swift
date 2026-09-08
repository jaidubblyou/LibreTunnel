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

/// Errors from format selection itself, as opposed to parsing a
/// recognized format (see `STLImportError`/`OBJImportError` for those).
public enum GeometryImportError: Error, Equatable {
    case unsupportedFileExtension(String)
}

extension GeometryImportError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unsupportedFileExtension(let ext):
            return ext.isEmpty
                ? "This file has no extension, so LibreTunnel can't tell what format it is. Supported formats: STL, OBJ."
                : "\".\(ext)\" isn't a supported format yet. Supported formats: STL, OBJ."
        }
    }
}

/// Picks the right format-specific importer based on file extension.
///
/// This is the single entry point the app should use to import
/// geometry — keeping "which formats are supported and how do we tell
/// them apart" inside `GeometryKit` rather than duplicated or
/// hard-coded in the UI layer, consistent with the project's layering
/// (`architecture.md`).
public enum GeometryImporter {
    public static func importMesh(from url: URL) throws -> TriangleMesh {
        switch url.pathExtension.lowercased() {
        case "stl":
            return try STLImporter.importMesh(from: url)
        case "obj":
            return try OBJImporter.importMesh(from: url)
        default:
            throw GeometryImportError.unsupportedFileExtension(url.pathExtension)
        }
    }
}
