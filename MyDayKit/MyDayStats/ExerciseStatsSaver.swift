//
//  ExerciseStatsSaver.swift
//  MyDayKit
//
//  Created by Findlay Wood on 12/11/2025.
//

import Foundation

public protocol ExerciseStatsSaver {
    func save(_ stats: ExerciseStatsSaveModel) async throws
}

struct PreviewExerciseStatsSaver: ExerciseStatsSaver {
    func save(_ stats: ExerciseStatsSaveModel) async throws {
        print("Saving stats: \(stats)")
    }
}
