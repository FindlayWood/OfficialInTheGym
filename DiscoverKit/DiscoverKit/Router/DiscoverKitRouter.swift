//
//  DiscoverKitRouter.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import SwiftUI
import UIKit

/// The DISCOVER tab's router, in the shape `StatsKitRouter` set: every
/// dependency through `public init`, `start()` sets the root, and
/// `viewController(for:)` is the one place a view model meets its screen.
///
/// Taps on a clip, workout or exercise lead nowhere yet — their detail screens
/// arrive with ratings, comments and the clip player (plan steps 3, 4 and 7),
/// and those routes are added then rather than stubbed now.
public final class DiscoverKitRouter {

    // MARK: - Navigation

    let navigationController: UINavigationController

    // MARK: - Dependencies

    let clipLoader: DiscoverClipCardLoader
    let workoutLoader: DiscoverWorkoutCardLoader
    let exerciseLoader: DiscoverExerciseCardLoader

    // MARK: - Properties

    private(set) var rootViewController: UIViewController?

    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        clipLoader: DiscoverClipCardLoader,
        workoutLoader: DiscoverWorkoutCardLoader,
        exerciseLoader: DiscoverExerciseCardLoader
    ) {
        self.navigationController = navigationController
        self.clipLoader = clipLoader
        self.workoutLoader = workoutLoader
        self.exerciseLoader = exerciseLoader
    }

    // MARK: - Root

    @MainActor
    public func start() {
        let rootVC = viewController(for: .home)
        rootViewController = rootVC
        navigationController.setViewControllers([rootVC], animated: false)
    }
}

extension DiscoverKitRouter {

    @MainActor
    func viewController(for route: DiscoverKitRoutes) -> UIViewController {
        switch route {
        case .home:
            let viewModel = DiscoverHomeViewModel(
                clipLoader: clipLoader,
                workoutLoader: workoutLoader,
                exerciseLoader: exerciseLoader
            )
            viewModel.onSeeAllClips = { [weak self] in self?.navigate(to: .allClips) }
            viewModel.onSeeAllWorkouts = { [weak self] in self?.navigate(to: .allWorkouts) }
            viewModel.onSeeAllExercises = { [weak self] in self?.navigate(to: .allExercises) }
            let vc = DiscoverKitBoundaryViewController()
            vc.display = DiscoverHomeScreen(viewModel: viewModel)
            vc.router = self
            return vc

        case .allClips:
            let pager = DiscoverPager<DiscoverClipCard> { [clipLoader] limit, last in
                try await clipLoader.load(limit: limit, after: last)
            }
            let vc = UIHostingController(
                rootView: DiscoverClipGridScreen(pager: pager, onTap: { _ in })
            )
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .allWorkouts:
            let pager = DiscoverPager<DiscoverWorkoutCard> { [workoutLoader] limit, last in
                try await workoutLoader.load(limit: limit, after: last)
            }
            let vc = UIHostingController(
                rootView: DiscoverCardListScreen(
                    title: "Workouts",
                    emptyMessage: "No public workouts yet",
                    pager: pager,
                    onTap: { _ in },
                    row: { DiscoverWorkoutRow(card: $0) }
                )
            )
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .allExercises:
            let pager = DiscoverPager<DiscoverExerciseCard> { [exerciseLoader] limit, last in
                try await exerciseLoader.load(limit: limit, after: last)
            }
            let vc = UIHostingController(
                rootView: DiscoverCardListScreen(
                    title: "Exercises",
                    emptyMessage: "No exercises yet",
                    pager: pager,
                    onTap: { _ in },
                    row: { DiscoverExerciseRow(card: $0) }
                )
            )
            vc.hidesBottomBarWhenPushed = true
            return vc
        }
    }

    @MainActor
    func navigate(to route: DiscoverKitRoutes) {
        navigationController.pushViewController(viewController(for: route), animated: true)
    }
}
