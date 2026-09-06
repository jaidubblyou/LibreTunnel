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

import XCTest
@testable import AppCore

final class AppInfoTests: XCTestCase {
    func testDescribingFormatsAllFields() {
        let info = AppInfo(name: "LibreTunnel", version: "0.1.0", build: "42")
        XCTAssertEqual(info.describing, "LibreTunnel 0.1.0 (42)")
    }

    func testEquality() {
        let a = AppInfo(name: "LibreTunnel", version: "0.1.0", build: "1")
        let b = AppInfo(name: "LibreTunnel", version: "0.1.0", build: "1")
        let c = AppInfo(name: "LibreTunnel", version: "0.2.0", build: "1")
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    func testCurrentFallsBackToDevelopmentDefaultsOutsideAnAppBundle() {
        // Under `swift test` there is no app bundle / Info.plist, so `current`
        // must fall back sensibly rather than crash or return empty strings.
        let info = AppInfo.current
        XCTAssertFalse(info.name.isEmpty)
        XCTAssertFalse(info.version.isEmpty)
        XCTAssertFalse(info.build.isEmpty)
    }
}
