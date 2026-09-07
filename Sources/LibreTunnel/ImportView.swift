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

import SwiftUI
import UniformTypeIdentifiers

/// The Import stage's real content.
///
/// This is the first workflow stage to move beyond `StagePlaceholderView`
/// — it can genuinely import an STL file and show what was parsed.
/// Geometry validation, repair, OBJ support, and the 3D viewport are
/// still not implemented; this view says so explicitly rather than
/// implying more than exists, per the project's "no fake functionality"
/// principle.
struct ImportView: View {
    @State private var viewModel = ImportViewModel()
    @State private var isPickerPresented = false

    private var stlContentType: UTType {
        UTType(filenameExtension: "stl") ?? .data
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                idleContent
            case .importing(let fileName):
                ProgressView("Importing \(fileName)…")
            case .imported(let fileName, let summary):
                importedContent(fileName: fileName, summary: summary)
            case .failed(let fileName, let message):
                failedContent(fileName: fileName, message: message)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .fileImporter(
            isPresented: $isPickerPresented,
            allowedContentTypes: [stlContentType],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    viewModel.importSTL(from: url)
                }
            case .failure(let error):
                viewModel.reportPickerFailure(error)
            }
        }
    }

    private var idleContent: some View {
        VStack(spacing: 12) {
            Image(systemName: WorkflowStage.importGeometry.systemImage)
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Import a 3D Model")
                .font(.title2)
                .bold()
            Text("STL files are supported. OBJ support is planned — see the roadmap.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
            Button("Choose STL File…") {
                isPickerPresented = true
            }
        }
    }

    private func importedContent(fileName: String, summary: ImportViewModel.MeshSummary) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 40))
                .foregroundStyle(.green)
            Text(fileName)
                .font(.headline)
            Text("\(summary.vertexCount) vertices · \(summary.triangleCount) triangles")
                .foregroundStyle(.secondary)
            if let size = summary.boundingSize {
                Text(String(format: "Bounding box: %.3f × %.3f × %.3f (model units)", size.x, size.y, size.z))
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
            Text("Geometry validation and the 3D viewport aren't implemented yet — this is a parse summary only.")
                .font(.footnote)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
                .padding(.top, 4)
            Button("Choose a Different File…") {
                isPickerPresented = true
            }
            .padding(.top, 4)
        }
    }

    private func failedContent(fileName: String, message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            Text("Couldn't import \(fileName)")
                .font(.headline)
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)
            Button("Try Again…") {
                isPickerPresented = true
            }
            .padding(.top, 4)
        }
    }
}

#Preview {
    ImportView()
}
