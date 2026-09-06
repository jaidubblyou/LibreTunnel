// swift-tools-version:5.10
// SPDX-License-Identifier: GPL-3.0-or-later
import PackageDescription

// LibreTunnel is built as a plain Swift Package (no .xcodeproj) so that the
// build is reproducible from the command line, in CI, and in Xcode without
// any project-file lock-in — see Documentation/adr/0002 and architecture.md.
//
// Module map (kept intentionally small in Phase 1; grows one module per phase):
//   LibreTunnel  — the SwiftUI app shell (executable target)
//   AppCore      — shared, pure-Swift models/utilities with no UI or OpenFOAM
//                  dependencies, used by both the app and (later) every other
//                  module. Introduced now so the multi-target wiring itself
//                  is proven and tested before real feature modules land.
let package = Package(
    name: "LibreTunnel",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "LibreTunnel", targets: ["LibreTunnel"]),
        .library(name: "AppCore", targets: ["AppCore"])
    ],
    targets: [
        .executableTarget(
            name: "LibreTunnel",
            dependencies: ["AppCore"],
            path: "Sources/LibreTunnel"
        ),
        .target(
            name: "AppCore",
            path: "Sources/AppCore"
        ),
        .testTarget(
            name: "AppCoreTests",
            dependencies: ["AppCore"],
            path: "Tests/AppCoreTests"
        )
    ]
)
