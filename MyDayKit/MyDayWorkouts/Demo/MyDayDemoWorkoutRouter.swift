//
//  MyDayDemoWorkoutRouter.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI
import UIKit

/// Lets someone who has not signed up yet run a workout — `MyDayDemoWorkout` —
/// on the real session and summary screens, so what they try is what they get.
///
/// **Nothing is saved, by construction.** The `WorkoutSessionManager` built
/// here has none of its callbacks wired — no `onEntryUpdated`, `onSetLogged`,
/// `onSetUnlogged` or `onSessionFinished` — and those are the only way a
/// session reaches disk or Firestore. There is no user to save for, and a
/// demo set landing in someone's stats after they sign up would be a lie. Do
/// not wire a saver into this flow.
///
/// It is also MyDay's "Practice workout" in Getting Started, after signup. There
/// it is built with no `onSignUp`, and the finished screen drops Create Account
/// and says the session was practice.
///
/// It pushes onto the navigation stack it is given (LoginKit's), so back from
/// the session returns to the welcome screen. "Complete Workout" lands on
/// `MyDayDemoWorkoutFinishedScreen`, whose Create Account calls `onSignUp` —
/// LoginKit owns signup, so the router only raises the intent. The screens' closures hold the router strongly: it has no other
/// owner, and it lives exactly as long as its screens are on the stack.
public final class MyDayDemoWorkoutRouter {

    // MARK: - Navigation

    private weak var navigationController: UINavigationController?

    // MARK: - Dependencies

    private let onSignUp: (() -> Void)?
    /// Opens the STATS preview from the finished screen. MyDayKit does not import StatsKit, so the
    /// app supplies it.
    private let onSeeStats: (() -> Void)?

    // MARK: - Properties

    /// The screen the demo was pushed from — what back and completion return to.
    private weak var rootViewController: UIViewController?

    // MARK: - Init

    public init(navigationController: UINavigationController, onSignUp: (() -> Void)? = nil, onSeeStats: (() -> Void)? = nil) {
        self.navigationController = navigationController
        self.onSignUp = onSignUp
        self.onSeeStats = onSeeStats
    }

    // MARK: - Root

    public func start() {
        guard let navigationController else { return }
        rootViewController = navigationController.topViewController

        let manager = WorkoutSessionManager(entry: MyDayDemoWorkout.entry(), userId: MyDayDemoWorkout.userId)
        let initialSetCount = manager.totalSetsTargeted
        let screen = MyDayWorkoutSessionScreen(
            manager: manager,
            userId: MyDayDemoWorkout.userId,
            onGoToSummary: { self.showSummary(manager: manager) },
            onBack: { self.popToRoot() },
            onCancelled: { self.popToRoot() },
            canAddSets: true,
            showsClips: false,
            notice: { MyDayDemoHint.notice(for: $0, initialSetCount: initialSetCount) },
            confirmsCancel: false
        )
        let vc = NavBarHidingHostingController(rootView: screen)
        // Pushed onto MyDay's stack from Getting Started, under the tab bar —
        // which would sit over the start and finish bars. LoginKit's stack has
        // no tab bar, so this changes nothing there.
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Navigation

extension MyDayDemoWorkoutRouter {

    private func showSummary(manager: WorkoutSessionManager) {
        let screen = WorkoutSessionSummaryScreen(
            manager: manager,
            endedAt: Date(),
            onComplete: { self.showFinished(manager: manager) },
            onBack: { self.navigationController?.popViewController(animated: true) }
        )
        let vc = NavBarHidingHostingController(rootView: screen)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    /// Replaces the session and summary rather than pushing over them, so
    /// swiping back from here returns to the welcome screen — not to a summary
    /// whose session has already finished.
    private func showFinished(manager: WorkoutSessionManager) {
        guard let navigationController else { return }
        let record = manager.sessionRecord
        let duration = record.flatMap { record in
            record.endedAt.map { Int($0.timeIntervalSince(record.startedAt)) }
        } ?? 0

        let screen = MyDayDemoWorkoutFinishedScreen(
            setsLogged: manager.totalSetsLogged,
            durationSeconds: duration,
            exerciseCount: manager.entry.template.exercises.count,
            onCreateAccount: onSignUp.map { signUp in { signUp() } },
            onBack: { self.popToRoot() },
            onSeeStats: onSeeStats
        )
        let vc = NavBarHidingHostingController(rootView: screen)
        vc.hidesBottomBarWhenPushed = true

        var stack = navigationController.viewControllers
        if let rootViewController, let rootIndex = stack.firstIndex(of: rootViewController) {
            stack = Array(stack.prefix(through: rootIndex))
        }
        navigationController.setViewControllers(stack + [vc], animated: true)
    }

    private func popToRoot() {
        guard let navigationController else { return }
        if let rootViewController {
            navigationController.popToViewController(rootViewController, animated: true)
        } else {
            navigationController.popViewController(animated: true)
        }
    }
}
