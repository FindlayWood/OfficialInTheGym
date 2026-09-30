//
//  DiscoverKitComposition.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import UIKit
import DiscoverKit


class DiscoverKitComposition {

    @MainActor
    func composeCombination(_ navigationController: UINavigationController) {

        // MARK: - Card loaders

        let clipLoader: DiscoverClipCardLoader = FirestoreDiscoverClipCardLoader()

        let workoutLoader: DiscoverWorkoutCardLoader = FirestoreDiscoverWorkoutCardLoader()

        let exerciseLoader: DiscoverExerciseCardLoader = FirestoreDiscoverExerciseCardLoader()

        // MARK: - Ratings

        let userId = UserDefaults.currentUser.uid

        let ratingSummaryLoader: RatingSummaryLoader = FirestoreRatingSummaryLoader()

        let myRatingLoader: MyRatingLoader = FirestoreMyRatingLoader(userId: userId)

        let ratingWriter: RatingWriter = FirestoreRatingWriter(userId: userId)

        // MARK: - Router

        let router = DiscoverKitRouter(
            navigationController: navigationController,
            clipLoader: clipLoader,
            workoutLoader: workoutLoader,
            exerciseLoader: exerciseLoader,
            ratingSummaryLoader: ratingSummaryLoader,
            myRatingLoader: myRatingLoader,
            ratingWriter: ratingWriter,
            currentUserId: userId
        )

        router.start()
    }
}
