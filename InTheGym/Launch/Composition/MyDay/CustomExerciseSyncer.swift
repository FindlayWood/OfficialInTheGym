//
//  CustomExerciseSyncer.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Tries the remote write and, if it fails, queues the exercise for
/// `CustomExerciseSyncService` to retry — `WorkoutTemplateSyncer`'s shape.
final class CustomExerciseSyncer: CustomExerciseUploading {

    private let remote: CustomExerciseUploading
    private let queue: CustomExerciseUploading

    init(remote: CustomExerciseUploading, queue: CustomExerciseUploading) {
        self.remote = remote
        self.queue = queue
    }

    func upload(_ exercise: CustomExercise) async throws {
        do {
            try await remote.upload(exercise)
        } catch {
            try await queue.upload(exercise)
        }
    }
}
