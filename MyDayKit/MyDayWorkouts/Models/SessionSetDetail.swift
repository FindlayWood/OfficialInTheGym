//
//  SessionSetDetail.swift
//  MyDayKit
//
//  Created by Findlay Wood on 30/06/2026.
//

import Foundation

struct SessionSetDetail {
    let exercise: WorkoutExerciseModel
    let setModel: WorkoutSetModel
    let setRecord: WorkoutSetRecord?
    let index: Int

    /// Namespace key for the pill → detail hero transition. Set ids are only
    /// unique within an exercise, so the exercise id is prefixed.
    var matchedId: String { SessionSetDetail.matchedId(exerciseId: exercise.id, setId: setModel.id) }

    static func matchedId(exerciseId: String, setId: String) -> String {
        "\(exerciseId)-\(setId)"
    }
}
