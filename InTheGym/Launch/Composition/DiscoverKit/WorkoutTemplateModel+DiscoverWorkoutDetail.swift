//
//  WorkoutTemplateModel+DiscoverWorkoutDetail.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import Foundation
import MyDayKit

/// MyDayKit's template as DiscoverKit's read-only page model. The only place
/// the two meet; units travel as their raw values, which are already how they
/// read ("kg", "% of 1RM", "km").
extension WorkoutTemplateModel {

    var discoverDetail: DiscoverWorkoutDetail {
        DiscoverWorkoutDetail(
            templateId: id,
            title: title,
            description: description,
            createdBy: createdBy,
            exercises: exercises.sorted { $0.orderIndex < $1.orderIndex }.map { exercise in
                DiscoverWorkoutExercise(
                    id: exercise.id,
                    name: exercise.exerciseName,
                    sets: exercise.sets.sorted { $0.orderIndex < $1.orderIndex }.map { set in
                        DiscoverWorkoutSet(
                            reps: set.reps,
                            weight: set.weight,
                            weightUnit: set.weightUnit?.rawValue,
                            time: set.time,
                            distance: set.distance,
                            distanceUnit: set.distanceUnit?.rawValue
                        )
                    },
                    notes: exercise.notes
                )
            }
        )
    }
}
