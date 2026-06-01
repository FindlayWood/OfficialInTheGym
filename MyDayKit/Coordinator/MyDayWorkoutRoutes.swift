//
//  MyDayWorkoutRoutes.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/05/2026.
//

import Foundation

enum MyDayWorkoutRoutes {
    case root
    case exercise
    case sets(WorkoutExerciseBuilderManager)
    case reps(WorkoutExerciseBuilderManager)
    case units(WorkoutExerciseBuilderManager)
    case weight(WorkoutExerciseBuilderManager)
    case distance(WorkoutExerciseBuilderManager)
    case time(WorkoutExerciseBuilderManager)
    case tempo(WorkoutExerciseBuilderManager)
    case note(WorkoutExerciseBuilderManager)
}

enum MyDayWorkoutSheets {
    case workoutSettings
}
