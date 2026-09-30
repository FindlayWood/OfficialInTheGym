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

        // MARK: - Router

        let router = DiscoverKitRouter(
            navigationController: navigationController,
            clipLoader: clipLoader,
            workoutLoader: workoutLoader,
            exerciseLoader: exerciseLoader
        )

        router.start()
    }
}
