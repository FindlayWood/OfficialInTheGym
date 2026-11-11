//
//  MyDayWorkoutLibraryRouter.swift
//  MyDayKit
//
//  Created by Findlay Wood on 11/11/2026.
//

import Combine
import UIKit

/// MyDay's workout page, opened on **another tab's** navigation stack (PROFILE, step 2 of
/// `PROFILE_WORKOUTS_PLAN.md`). Built like `MyDayDemoWorkoutRouter`: it pushes onto whatever stack
/// it is given and returns to the screen it was pushed from.
///
/// `MyDayWorkoutCoordinator` is internal and starts at the library, so another tab had no way to
/// open one workout. This exposes exactly that and nothing more. **The builder is deliberately not
/// here**, since building starts only from MyDay.
///
/// **It must be handed the same managers MyDay holds**, never new ones. A second day manager would
/// add a workout MyDay does not see until relaunch, and a second schedule manager would hold
/// schedules MyDay's due cards never read. Add to Today goes through `addWorkoutToToday`, which
/// targets today whatever day MyDay has open.
public final class MyDayWorkoutLibraryRouter {

    // MARK: - Navigation

    private weak var navigationController: UINavigationController?

    // MARK: - Dependencies

    private let libraryManager: WorkoutLibraryManager
    private let dayManager: MyDayManager
    /// `nil` leaves Schedule off the workout page.
    private let scheduleManager: ScheduleManager?

    // MARK: - Properties

    /// A workout asked for before the library had loaded, waiting for it. Replaced by the next
    /// request, so a tap that never resolved cannot open a page later on its own.
    private var pendingOpen: AnyCancellable?

    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        libraryManager: WorkoutLibraryManager,
        dayManager: MyDayManager,
        scheduleManager: ScheduleManager? = nil
    ) {
        self.navigationController = navigationController
        self.libraryManager = libraryManager
        self.dayManager = dayManager
        self.scheduleManager = scheduleManager
    }

    // MARK: - Root

    /// Pushes the workout page for one of the user's own workouts.
    ///
    /// The library is MyDay's, so it may not have loaded yet if the user has not opened it this
    /// session. Then this loads it and waits, giving up only when the load ends empty or failed.
    /// A library that has loaded without the workout opens nothing: it is not in this user's
    /// library, and there is no other copy MyDay's page could show.
    public func showTemplate(id: String) {
        pendingOpen = nil
        if let template = libraryManager.state.template(id: id) {
            push(template)
            return
        }
        if case .loaded = libraryManager.state {
            print("❌ Workout \(id) is not in the library")
            return
        }

        libraryManager.loadIfNeeded()
        // `first` so the page opens once: the library publishes `.loaded` again when the remote
        // merge lands, and a plain sink would push the page a second time.
        pendingOpen = libraryManager.$state
            .first { state in
                if state.template(id: id) != nil { return true }
                switch state {
                case .empty, .failed: return true
                // Local templates land first and the remote merge after, so a workout only on
                // the server shows up in a second `.loaded`.
                case .loading, .loaded: return false
                }
            }
            .sink { [weak self] state in
                guard let template = state.template(id: id) else {
                    print("❌ Workout \(id) is not in the library")
                    return
                }
                self?.push(template)
            }
    }
}

// MARK: - Navigation

extension MyDayWorkoutLibraryRouter {

    private func push(_ template: WorkoutTemplateModel) {
        guard let navigationController else { return }
        weak var origin = navigationController.topViewController

        let screen = MyDayWorkoutTemplateDetailScreen(
            template: template,
            scheduleManager: scheduleManager,
            onAddToTodayTapped: { [weak dayManager] in dayManager?.addWorkoutToToday($0) },
            onReadyToDismiss: { [weak navigationController] in
                guard let navigationController else { return }
                if let origin {
                    navigationController.popToViewController(origin, animated: true)
                } else {
                    navigationController.popViewController(animated: true)
                }
            },
            onBack: { [weak navigationController] in
                navigationController?.popViewController(animated: true)
            }
        )
        // Hosted with the nav bar hidden so the set detail overlay can dim the whole screen, as in
        // MyDay. Pushed over a tab bar, which would otherwise sit across Add to Today.
        let vc = NavBarHidingHostingController(rootView: screen)
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}
