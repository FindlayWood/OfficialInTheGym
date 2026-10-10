//
//  PerformanceKitRoutes.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import UIKit

/// Every screen PerformanceKit can show. Each test adds its screens here
/// (`PERFORMANCE_PLAN.md`, part 2).
enum PerformanceKitRoutes {
    case home

    // MARK: - Vertical Jump
    case verticalJump
    case previousJumps
    case jumpInstructions
    /// The camera, presented full screen. Carries the best the home screen
    /// loaded, through the replay to the result, so it is not read again.
    case jumpRecorder(max: VerticalJump?)
    case jumpReplay(fileURL: URL, max: VerticalJump?)
    case jumpResult(height: Double, max: VerticalJump?)
}
