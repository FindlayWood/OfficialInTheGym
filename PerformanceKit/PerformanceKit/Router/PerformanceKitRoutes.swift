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

    // MARK: - Jump tests
    case jumpTestHome(JumpTestKind)
    case jumpTestHistory(JumpTestKind)
    /// How a test works, as a sheet: a jump test's or balance's steps.
    case instructions(title: String, steps: [JumpInstruction])

    // MARK: - Jump engine
    /// A sitting of a jump test, presented full screen. `onSaved` hands the
    /// saved session back to the screen that started it.
    case jumpTest(JumpTestKind, onSaved: (JumpTestSession) -> Void)
    /// The camera, presented over the session. `onMeasured` carries the
    /// attempt back once it is tagged.
    case jumpRecorder(JumpTestKind, onMeasured: (JumpAttempt) -> Void)
    case jumpReplay(fileURL: URL, kind: JumpTestKind, onMeasured: (JumpAttempt) -> Void)
    /// Shown in place of the camera when it cannot run (`JumpCameraAvailability`).
    case jumpCameraUnavailable(JumpCameraAvailability, kind: JumpTestKind, onMeasured: (JumpAttempt) -> Void)

    // MARK: - Balance
    case balanceHome
    /// Carries the home's view model: the history is the sessions it loaded.
    case balanceHistory(BalanceHomeViewModel)
    case balanceTest(onSaved: (BalanceSession) -> Void)
    /// One stand, presented over the session.
    case balanceRecording(side: JumpSide, condition: BalanceCondition, onKeep: (BalanceAttempt) -> Void)
}
