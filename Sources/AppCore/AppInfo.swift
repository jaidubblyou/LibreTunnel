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

/// Version and build metadata for LibreTunnel.
///
/// This exists from Phase 1 onward because it directly supports the
/// project's reproducibility goal: every saved project file and every
/// generated OpenFOAM case should be traceable back to the exact
/// application version that produced it (see Documentation/architecture.md,
/// "Reproducibility"). `ProjectKit`, once it exists, will embed this in
/// saved-project metadata; for now the app shell uses it to show a version
/// string in the UI.
public struct AppInfo: Equatable, Sendable {
    public let name: String
    public let version: String
    public let build: String

    public init(name: String, version: String, build: String) {
        self.name = name
        self.version = version
        self.build = build
    }

    /// The running application's info, sourced from the bundle's Info.plist
    /// where available, falling back to development defaults when running
    /// outside an app bundle (for example, under `swift test`, where there
    /// is no Info.plist to read).
    public static var current: AppInfo {
        let bundle = Bundle.main
        let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "LibreTunnel"
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0-dev"
        let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        return AppInfo(name: name, version: version, build: build)
    }

    /// A single string suitable for logs, saved-project metadata, the
    /// window's navigation subtitle, and bug reports.
    public var describing: String {
        "\(name) \(version) (\(build))"
    }
}
