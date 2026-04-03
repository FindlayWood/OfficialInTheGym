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
        
        let exerciseLoader = RemoteStatsKitExerciseLoader()
        
        let recentExerciseLoader = RemoteRecentStatsKitExerciseLoader()
        
        let exerciseDailyStatsLoader = RemoteExerciseDailyStatsLoader()
        
        let router = StatsKitRouter(
            navigationController: navigationController,
            dailyTotalLoader: dailyTotalLoader,
            exerciseLoader: exerciseLoader,
            recentExerciseLoader: recentExerciseLoader,
            exerciseDailyStatsLoader: exerciseDailyStatsLoader
        )
        
        router.start()
    }
    
}
