//
//  StatsKitComposition.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/03/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import UIKit
import StatsKit

class StatsKitComposition {
    
    @MainActor
    func composeCombination(_ navigationController: UINavigationController, purchaseManager: PurchaseManager) {
        
        let dailyTotalLoader = StatsKitDailyTotalsLoader()
        
        let exerciseStatsLoader = RemoteStatsKitExerciseLoader()
        
        let recentExerciseLoader = RemoteRecentStatsKitExerciseLoader()
        
        let exerciseDailyStatsLoader = RemoteExerciseDailyStatsLoader()
        
        let exerciseLoader = RemoteExerciseLoader()
        
        let muscleGroupLoader = RemoteMuscleGroupsLoader()
        
        let movementTypeLoader = RemoteMovementTypesLoader()

        // MARK: - Pro
        // The whole tab is pro, re-checked each time it appears.
        let proAccess: StatsProAccess = PurchaseManagerProAccess(purchaseManager: purchaseManager)
        
        let router = StatsKitRouter(
            navigationController: navigationController,
            dailyTotalLoader: dailyTotalLoader,
            exerciseStatsLoader: exerciseStatsLoader,
            recentExerciseLoader: recentExerciseLoader,
            exerciseDailyStatsLoader: exerciseDailyStatsLoader,
            exerciseLoader: exerciseLoader,
            muscleGroupLoader: muscleGroupLoader,
            movementTypeLoader: movementTypeLoader,
            proAccess: proAccess
        )
        router.onShowPaywall = { [weak navigationController] in
            navigationController?.present(ProPaywallViewController.modal(purchaseManager: purchaseManager), animated: true)
        }

        router.start()
    }
    
}
