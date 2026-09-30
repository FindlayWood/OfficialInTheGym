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
/// Exercises and workouts open their detail screens. A clip tap leads nowhere
/// yet — the clip player arrives with comments and likes (plan step 4), and
/// its route is added then rather than stubbed now.
///
/// `currentUserId` is the signed-in user, read once in the composition root.
/// The router needs it for one decision only: a user cannot rate their own
/// workout.
public final class DiscoverKitRouter {

    // MARK: - Navigation

    let navigationController: UINavigationController

    // MARK: - Dependencies

    let clipLoader: DiscoverClipCardLoader
    let workoutLoader: DiscoverWorkoutCardLoader
    let exerciseLoader: DiscoverExerciseCardLoader
    let ratingSummaryLoader: RatingSummaryLoader
    let myRatingLoader: MyRatingLoader
    let ratingWriter: RatingWriter
    let currentUserId: String

    // MARK: - Properties

    private(set) var rootViewController: UIViewController?

    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        clipLoader: DiscoverClipCardLoader,
        workoutLoader: DiscoverWorkoutCardLoader,
        exerciseLoader: DiscoverExerciseCardLoader,
        ratingSummaryLoader: RatingSummaryLoader,
        myRatingLoader: MyRatingLoader,
        ratingWriter: RatingWriter,
        currentUserId: String
    ) {
        self.navigationController = navigationController
        self.clipLoader = clipLoader
        self.workoutLoader = workoutLoader
        self.exerciseLoader = exerciseLoader
        self.ratingSummaryLoader = ratingSummaryLoader
        self.myRatingLoader = myRatingLoader
        self.ratingWriter = ratingWriter
        self.currentUserId = currentUserId
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
            viewModel.onWorkoutTapped = { [weak self] in self?.navigate(to: .workoutDetail($0)) }
            viewModel.onExerciseTapped = { [weak self] in self?.navigate(to: .exerciseDetail($0)) }
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
                    onTap: { [weak self] in self?.navigate(to: .workoutDetail($0)) },
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
                    onTap: { [weak self] in self?.navigate(to: .exerciseDetail($0)) },
                    row: { DiscoverExerciseRow(card: $0) }
                )
            )
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .exerciseDetail(let card):
            let ratingViewModel = makeRatingViewModel(
                subject: .exercise(id: card.exerciseId),
                summary: card.ratingSummary,
                canRate: true
            )
            let vc = UIHostingController(
                rootView: DiscoverExerciseDetailScreen(card: card, ratingViewModel: ratingViewModel)
            )
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .workoutDetail(let card):
            let ratingViewModel = makeRatingViewModel(
                subject: .workout(id: card.templateId),
                summary: card.ratingSummary,
                canRate: card.createdBy != currentUserId
            )
            let vc = UIHostingController(
                rootView: DiscoverWorkoutDetailScreen(card: card, ratingViewModel: ratingViewModel)
            )
            vc.hidesBottomBarWhenPushed = true
            return vc
        }
    }

    @MainActor
    private func makeRatingViewModel(
        subject: DiscoverSubject,
        summary: RatingSummary,
        canRate: Bool
    ) -> DiscoverRatingViewModel {
        DiscoverRatingViewModel(
            subject: subject,
            initialSummary: summary,
            canRate: canRate,
            summaryLoader: ratingSummaryLoader,
            myRatingLoader: myRatingLoader,
            writer: ratingWriter
        )
    }

    @MainActor
    func navigate(to route: DiscoverKitRoutes) {
        navigationController.pushViewController(viewController(for: route), animated: true)
    }
}
