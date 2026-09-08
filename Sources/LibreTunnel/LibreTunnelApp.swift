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
import AppKit

/// Explicitly claims "regular app" status (Dock icon, Cmd+Tab presence,
/// menu bar) on launch.
///
/// This is a no-op once the app is packaged as a real `.app` bundle
/// (`Scripts/build-app-bundle.sh`) and launched normally — a bundled,
/// non-`LSUIElement` app already gets `.regular` by default. It matters
/// specifically for `swift run` during development: without a bundle,
/// macOS doesn't reliably give the bare executable full app treatment,
/// so the window works (visible in Mission Control, on the desktop) but
/// no Dock icon appears. See `Documentation/developer-setup.md` for the
/// full explanation — this was a real question during Phase 2 testing,
/// not a hypothetical.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate()
    }
}

/// Application entry point.
///
/// Phase 1 scope only: a launching native window with the primary workflow
/// navigation (Import → Inspect → Tunnel → Simulate → Analyse) in place as
/// placeholders. No geometry, meshing, OpenFOAM, or rendering functionality
/// exists yet — see Documentation/architecture.md for the phased roadmap.
@main
struct LibreTunnelApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}
