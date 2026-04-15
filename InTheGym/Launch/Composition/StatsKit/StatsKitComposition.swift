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
    
    func composeCombination(_ navigationController: UINavigationController) {
        
        let dailyTotalLoader = StatsKitDailyTotalsLoader()
        
        let exerciseStatsLoader = RemoteStatsKitExerciseLoader()
        
        let recentExerciseLoader = RemoteRecentStatsKitExerciseLoader()
        
        let exerciseDailyStatsLoader = RemoteExerciseDailyStatsLoader()
        
        let exerciseLoader = RemoteExerciseLoader()
        
        let muscleGroupLoader = RemoteMuscleGroupsLoader()
        
        let movementTypeLoader = RemoteMovementTypesLoader()
        
        let router = StatsKitRouter(
            navigationController: navigationController,
            dailyTotalLoader: dailyTotalLoader,
            exerciseStatsLoader: exerciseStatsLoader,
            recentExerciseLoader: recentExerciseLoader,
            exerciseDailyStatsLoader: exerciseDailyStatsLoader,
            exerciseLoader: exerciseLoader,
            muscleGroupLoader: muscleGroupLoader,
            movementTypeLoader: movementTypeLoader
        )
        
        router.start()
    }
    
}
