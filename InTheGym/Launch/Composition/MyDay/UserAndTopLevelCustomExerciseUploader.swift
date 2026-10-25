//
//  UserAndTopLevelCustomExerciseUploader.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Writes a custom exercise to the creator's copy, then the review copy. It
/// knows no paths — each destination is its own writer, and this only decides
/// that both happen and in what order. The template pipeline's
/// `UserAndTopLevelWorkoutTemplateUploader`, for the same reasons.
///
/// **The user copy goes first** because it is the one the picker reads back.
/// **Either failure throws**, so `CustomExerciseSyncer` queues the exercise and
/// `CustomExerciseSyncService` retries the whole composition; both writes are
/// idempotent merges, so a retry after the first landed rewrites it rather than
/// duplicating anything.
final class UserAndTopLevelCustomExerciseUploader: CustomExerciseUploading {

    private let user: CustomExerciseUploading
    private let topLevel: CustomExerciseUploading

    init(user: CustomExerciseUploading, topLevel: CustomExerciseUploading) {
        self.user = user
        self.topLevel = topLevel
    }

    func upload(_ exercise: CustomExercise) async throws {
        try await user.upload(exercise)
        try await topLevel.upload(exercise)
    }
}
