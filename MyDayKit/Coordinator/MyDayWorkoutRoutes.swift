//
//  MyDayWorkoutRoutes.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/05/2026.
//

import Foundation

enum MyDayWorkoutRoutes {
    case library
    case templateDetail(WorkoutTemplateModel)
    case creation
    case exercise
    /// The custom exercise form, its name filled in from the picker's search.
    case createExercise(String)
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
