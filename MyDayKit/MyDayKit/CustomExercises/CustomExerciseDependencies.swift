//
//  CustomExerciseDependencies.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// Everything the custom exercise form needs, handed down as one value.
///
/// Both of MyDay's coordinators open the form — logging an exercise and
/// building a workout share `MyDayExerciseListView` — so these travel from
/// `MyDayCoordinator` into `MyDayWorkoutCoordinator` too. Four loose
/// parameters on two initialisers would be the same list written twice.
public struct CustomExerciseDependencies {
    /// The composed writer: local file first, then both Firestore copies.
    let saver: CustomExerciseUploading
    let muscleGroups: ExerciseMuscleGroupsLoader
    let movementPatterns: ExerciseMovementPatternsLoader
    /// The creator — the signed-in user, read once in the composition root.
    let userId: String

    public init(
        saver: CustomExerciseUploading,
        muscleGroups: ExerciseMuscleGroupsLoader,
        movementPatterns: ExerciseMovementPatternsLoader,
        userId: String
    ) {
        self.saver = saver
        self.muscleGroups = muscleGroups
        self.movementPatterns = movementPatterns
        self.userId = userId
    }
}
