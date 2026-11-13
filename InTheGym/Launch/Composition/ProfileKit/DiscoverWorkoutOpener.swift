//
//  DiscoverWorkoutOpener.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import DiscoverKit
import ProfileKit
import UIKit

/// Opens a profile's public workout on DISCOVER's workout page (ratings, comments, tags, report),
/// pushed onto the profile's own navigation stack by a DiscoverKit router built there
/// (`PROFILE_WORKOUTS_PLAN.md` step 5). The workout twin of `DiscoverClipOpener`.
///
/// **The router is built lazily, on the first tap**: `DiscoverKitComposition` builds a ProfileKit
/// router for its author links, and `ProfileKitComposition` builds one of these, so building
/// eagerly would recurse forever. It holds the navigation controller weakly, because the
/// navigation controller (through its screens' router) holds it.
///
/// It is handed MyDay's workout library where there is one, so Save to Library works on someone
/// else's workout, exactly as on DISCOVER. A `ProfileWorkout` from a public list carries every field
/// the page needs from the card, so it maps straight to a `DiscoverWorkoutCard` with no second read.
final class DiscoverWorkoutOpener {

    private weak var navigationController: UINavigationController?
    private let workoutLibrary: MyDayWorkoutLibrary?
    private let purchaseManager: PurchaseManager
    private var router: DiscoverKitRouter?

    init(navigationController: UINavigationController, workoutLibrary: MyDayWorkoutLibrary?, purchaseManager: PurchaseManager) {
        self.navigationController = navigationController
        self.workoutLibrary = workoutLibrary
        self.purchaseManager = purchaseManager
    }

    func open(_ workout: ProfileWorkout) {
        MainActor.assumeIsolated {
            guard let navigationController else { return }
            let router = self.router ?? DiscoverKitComposition().makeRouter(
                navigationController,
                workoutLibrary: workoutLibrary,
                purchaseManager: purchaseManager
            )
            self.router = router
            router.showWorkout(DiscoverWorkoutCard(
                templateId: workout.workoutId,
                title: workout.title,
                createdBy: workout.createdBy,
                exerciseCount: workout.exerciseCount,
                createdAt: workout.createdAt,
                isPublic: workout.isPublic,
                ratingCount: workout.ratingCount,
                ratingSum: workout.ratingSum,
                commentCount: workout.commentCount,
                visibleTags: workout.tags
            ))
        }
    }
}
