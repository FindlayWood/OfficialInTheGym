//
//  MyDayProfileWorkoutOpener.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import MyDayKit
import UIKit

/// Opens one of your own workouts on MyDay's workout page (Add to Today, Schedule), pushed onto the
/// PROFILE tab's stack by a `MyDayWorkoutLibraryRouter` (`PROFILE_WORKOUTS_PLAN.md` step 5).
///
/// The router comes from `MyDayKitComposition.makeWorkoutLibraryRouter`, which closes over the
/// managers MyDay itself holds, so a workout added to today from here is on MyDay's today, and a
/// schedule made here shows on MyDay's due cards. Built on the first tap and kept, so a workout
/// asked for before MyDay's library has loaded still opens once it has.
final class MyDayProfileWorkoutOpener {

    private weak var navigationController: UINavigationController?
    private let makeRouter: (UINavigationController) -> MyDayWorkoutLibraryRouter
    private var router: MyDayWorkoutLibraryRouter?

    init(navigationController: UINavigationController, makeRouter: @escaping (UINavigationController) -> MyDayWorkoutLibraryRouter) {
        self.navigationController = navigationController
        self.makeRouter = makeRouter
    }

    func open(workoutId: String) {
        guard let navigationController else { return }
        let router = self.router ?? makeRouter(navigationController)
        self.router = router
        router.showTemplate(id: workoutId)
    }
}
