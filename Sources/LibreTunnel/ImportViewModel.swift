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
import Observation
import simd
import GeometryKit

/// Drives the Import stage's UI state.
///
/// `GeometryKit.STLImporter` is a synchronous, pure function by design
/// (see its documentation) — this view model is where the "keep the UI
/// responsive during import" requirement actually gets honoured, by
/// dispatching the parse work off the main actor and only touching
/// `state` back on it.
@MainActor
@Observable
final class ImportViewModel {
    enum State: Equatable {
        case idle
        case importing(fileName: String)
        case imported(fileName: String, summary: MeshSummary)
        case failed(fileName: String, message: String)
    }

    struct MeshSummary: Equatable {
        let vertexCount: Int
        let triangleCount: Int
        let boundingSize: SIMD3<Float>?
    }

    private(set) var state: State = .idle

    /// Explicit and `nonisolated` so this type can be constructed from a
    /// non-isolated context — specifically, a SwiftUI View's
    /// `@State private var viewModel = ImportViewModel()` property
    /// initializer, which the compiler does not treat as main-actor
    /// isolated even though the view itself always runs on the main
    /// thread. Without this, the class's implicit (main-actor-isolated,
    /// because the class is `@MainActor`) synthesized `init()` can't be
    /// called from that context. Safe here because the only thing this
    /// initializer does is apply `state`'s own default value
    /// (`= .idle`), which touches no actor-isolated data.
    nonisolated init() {}

    func importGeometry(from url: URL) {
        let fileName = url.lastPathComponent
        state = .importing(fileName: fileName)

        Task {
            do {
                let mesh = try await Task.detached(priority: .userInitiated) {
                    try GeometryImporter.importMesh(from: url)
                }.value

                let box = mesh.boundingBox
                let summary = MeshSummary(
                    vertexCount: mesh.vertexCount,
                    triangleCount: mesh.triangleCount,
                    boundingSize: box.map { $0.max - $0.min }
                )
                state = .imported(fileName: fileName, summary: summary)
            } catch {
                let message = (error as? LocalizedError)?.errorDescription ?? "\(error)"
                state = .failed(fileName: fileName, message: message)
            }
        }
    }

    func reportPickerFailure(_ error: Error) {
        state = .failed(fileName: "the selected file", message: error.localizedDescription)
    }
}
