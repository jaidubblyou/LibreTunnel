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
import AppCore

/// The application's primary window: a sidebar listing the five workflow
/// stages, with the selected stage's content in the detail pane.
///
/// Phase 1 only wires up navigation between placeholder views. Each stage's
/// real content lands in its corresponding roadmap phase (see
/// Documentation/architecture.md).
struct ContentView: View {
    @State private var selectedStage: WorkflowStage? = .importGeometry

    var body: some View {
        NavigationSplitView {
            List(WorkflowStage.allCases, selection: $selectedStage) { stage in
                Label(stage.title, systemImage: stage.systemImage)
                    .tag(stage)
            }
            .navigationTitle("LibreTunnel")
            .listStyle(.sidebar)
        } detail: {
            if let selectedStage {
                switch selectedStage {
                case .importGeometry:
                    ImportView()
                default:
                    StagePlaceholderView(stage: selectedStage)
                }
            } else {
                Text("Select a stage to begin.")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .navigationSubtitle(AppInfo.current.describing)
    }
}

#Preview {
    ContentView()
}
