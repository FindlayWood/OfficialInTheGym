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
    case acwrDetail(totals: [DailyTotal], metric: TrainingLoadMetric, injuries: [StatsInjury], readiness: [ReadinessDay])
    case injuryDetail(StatsInjury, totals: [DailyTotal], muscleGroups: [MuscleGroup], readiness: [ReadinessDay])
    case readinessDetail([ReadinessDay], injuries: [StatsInjury])
    case trainingBalance([DailyTotal], [MuscleGroup], [MovementPattern])
}
