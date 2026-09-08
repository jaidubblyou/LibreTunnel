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

/// Everything that can go wrong importing an OBJ file, each with a
/// message written for the person using the app — see `STLImportError`
/// for the same principle applied to STL.
public enum OBJImportError: Error, Equatable {
    case emptyFile
    case malformedVertex(line: Int, message: String)
    case malformedFace(line: Int, message: String)
    case faceIndexOutOfRange(line: Int, index: Int, vertexCount: Int)
    case unreadableFile(String)
}

extension OBJImportError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyFile:
            return "This OBJ file doesn't contain any faces."
        case .malformedVertex(let line, let message):
            return "Could not parse this OBJ file at line \(line): \(message)"
        case .malformedFace(let line, let message):
            return "Could not parse this OBJ file at line \(line): \(message)"
        case .faceIndexOutOfRange(let line, let index, let vertexCount):
            return "Line \(line) references vertex \(index), but only \(vertexCount) vertices have been defined so far. The file may be corrupted or out of order."
        case .unreadableFile(let reason):
            return "Could not read this file as OBJ: \(reason)"
        }
    }
}
