// swift-tools-version:5.10
// SPDX-License-Identifier: GPL-3.0-or-later
import PackageDescription

// LibreTunnel is built as a plain Swift Package (no .xcodeproj) so that the
// build is reproducible from the command line, in CI, and in Xcode without
// any project-file lock-in — see Documentation/adr/0002 and architecture.md.
//
// Module map (grows one module per phase — see Documentation/architecture.md):
//   LibreTunnel  — the SwiftUI app shell (executable target)
//   AppCore      — shared, pure-Swift models/utilities with no UI or OpenFOAM
//                  dependencies
//   GeometryKit  — STL/OBJ import and validation (Phase 2). Pure Swift, no
//                  UI or OpenFOAM dependency, so it's testable without an
//                  app bundle or a live OpenFOAM install.
let package = Package(
    name: "LibreTunnel",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "LibreTunnel", targets: ["LibreTunnel"]),
        .library(name: "AppCore", targets: ["AppCore"]),
        .library(name: "GeometryKit", targets: ["GeometryKit"])
    ],
    targets: [
        .executableTarget(
            name: "LibreTunnel",
            dependencies: ["AppCore", "GeometryKit"],
            path: "Sources/LibreTunnel"
        ),
        .target(
            name: "AppCore",
            path: "Sources/AppCore"
        ),
        .target(
            name: "GeometryKit",
            path: "Sources/GeometryKit"
        ),
        .testTarget(
            name: "AppCoreTests",
            dependencies: ["AppCore"],
            path: "Tests/AppCoreTests"
        ),
        .testTarget(
            name: "GeometryKitTests",
            dependencies: ["GeometryKit"],
            path: "Tests/GeometryKitTests"
        )
    ]
)
