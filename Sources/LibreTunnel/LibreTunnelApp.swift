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

/// Application entry point.
///
/// Phase 1 scope only: a launching native window with the primary workflow
/// navigation (Import → Inspect → Tunnel → Simulate → Analyse) in place as
/// placeholders. No geometry, meshing, OpenFOAM, or rendering functionality
/// exists yet — see Documentation/architecture.md for the phased roadmap.
@main
struct LibreTunnelApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}
