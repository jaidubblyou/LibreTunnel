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

/// A deliberately honest placeholder for workflow stages that are not yet
/// implemented.
///
/// This view exists so the application never silently pretends to have
/// functionality it doesn't (project "no fake functionality" policy). Once a
/// stage's real implementation lands, this view is replaced entirely for
/// that stage rather than dressed up to look more complete than it is.
struct StagePlaceholderView: View {
    let stage: WorkflowStage

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: stage.systemImage)
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(stage.title)
                .font(.title2)
                .bold()
            Text(stage.summary)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
            if !stage.isImplemented {
                Text("Not yet implemented — planned for a later roadmap phase.")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    StagePlaceholderView(stage: .simulate)
}
