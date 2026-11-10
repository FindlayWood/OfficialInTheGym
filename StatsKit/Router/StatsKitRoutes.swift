//
//  StatsKitRoutes.swift
//  StatsKit
//
//  Created by Findlay Wood on 19/03/2026.
//

import Foundation

enum StatsKitRoutes {
    case home
    case allExercises
    case exerciseDetail(exercise: ExerciseStats)
    case acwrDetail(totals: [DailyTotal], metric: TrainingLoadMetric, injuries: [StatsInjury])
    case injuryDetail(StatsInjury, totals: [DailyTotal], muscleGroups: [MuscleGroup])
    case trainingBalance([DailyTotal], [MuscleGroup], [MovementPattern])
}
