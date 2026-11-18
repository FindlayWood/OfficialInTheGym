//
//  WorkoutExerciseSetManager+SetModel.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import Foundation

extension WorkoutExerciseSetManager {

    /// The set as a template stores it. **The one mapping**: `buildTemplate()` saves through it and
    /// the builder's cards draw their pills from it, so what the builder shows is what is saved.
    func setModel(orderIndex: Int, id: String) -> WorkoutSetModel {
        WorkoutSetModel(
            id: id,
            orderIndex: orderIndex,
            reps: reps,
            weight: weight,
            weightUnit: weightUnits,
            time: time,
            distance: distance,
            distanceUnit: distanceUnits,
            tempo: tempo,
            note: note,
            eachSide: eachSide
        )
    }
}
