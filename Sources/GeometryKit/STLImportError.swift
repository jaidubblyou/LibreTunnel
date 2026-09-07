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

/// Everything that can go wrong importing an STL file, each with a
/// message written for the person using the app, not just a developer
/// — per the project's "failure handling" principle: every error needs
/// an understandable explanation, not a raw parser dump.
public enum STLImportError: Error, Equatable {
    case emptyFile
    case truncatedBinaryHeader
    case triangleCountMismatch(declared: Int, expectedBytes: Int, actualBytes: Int)
    case malformedASCII(line: Int, message: String)
    case unreadableFile(String)
}

extension STLImportError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyFile:
            return "This STL file doesn't contain any triangles."
        case .truncatedBinaryHeader:
            return "This file is too short to be a valid binary STL file (expected at least an 80-byte header and a triangle count)."
        case .triangleCountMismatch(let declared, let expectedBytes, let actualBytes):
            return "This binary STL file declares \(declared) triangle(s), which should be \(expectedBytes) bytes, but the file is \(actualBytes) bytes. It may be corrupted or truncated."
        case .malformedASCII(let line, let message):
            return "Could not parse this STL file at line \(line): \(message)"
        case .unreadableFile(let reason):
            return "Could not read this file as STL: \(reason)"
        }
    }
}
