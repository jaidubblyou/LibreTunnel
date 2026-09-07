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

/// The five stages of the LibreTunnel workflow: Import → Inspect → Tunnel →
/// Simulate → Analyse.
///
/// This enum drives the application's primary navigation. It exists as an
/// explicit, centralised model — rather than scattering stage names as
/// string literals through the UI — so that adding real functionality to a
/// stage in a later phase means changing one place, and so the UI can never
/// silently imply a stage does more than it currently does.
enum WorkflowStage: String, CaseIterable, Identifiable {
    case importGeometry
    case inspect
    case tunnel
    case simulate
    case analyse

    var id: String { rawValue }

    var title: String {
        switch self {
        case .importGeometry: return "Import"
        case .inspect: return "Inspect"
        case .tunnel: return "Tunnel"
        case .simulate: return "Simulate"
        case .analyse: return "Analyse"
        }
    }

    var systemImage: String {
        switch self {
        case .importGeometry: return "square.and.arrow.down"
        case .inspect: return "magnifyingglass"
        case .tunnel: return "wind"
        case .simulate: return "cpu"
        case .analyse: return "chart.xyaxis.line"
        }
    }

    /// One-line description of what this stage will do once implemented,
    /// shown in its placeholder view so the roadmap is visible in the app
    /// itself, not just in documentation.
    var summary: String {
        switch self {
        case .importGeometry:
            return "Drag in an STL or OBJ model."
        case .inspect:
            return "Review geometry validation results and repairs before proceeding."
        case .tunnel:
            return "Configure the virtual wind tunnel domain and airflow conditions."
        case .simulate:
            return "Run the OpenFOAM simulation locally and monitor convergence."
        case .analyse:
            return "Visualise pressure, velocity, streamlines, and aerodynamic forces."
        }
    }

    /// Whether this stage has real functionality behind it yet.
    ///
    /// Kept explicit and centralised so the UI never silently implies more
    /// capability than currently exists (project "no fake functionality"
    /// policy). "Implemented" here means "has genuine functionality," not
    /// necessarily "complete" — Import can parse STL files (Phase 2,
    /// first slice) but doesn't yet validate geometry, support OBJ, or
    /// show a 3D viewport; `ImportView` is explicit about that narrower
    /// scope in its own UI text.
    var isImplemented: Bool {
        switch self {
        case .importGeometry: return true
        case .inspect, .tunnel, .simulate, .analyse: return false
        }
    }
}
