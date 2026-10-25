//
//  CustomExerciseSaver.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// The writer MyDayKit is handed: local first, then remote in the background —
/// `WorkoutTemplateSaver`'s shape.
///
/// **Only the local write can fail the save.** Once the file is on disk the
/// exercise exists and can be picked; the remote copies are the syncer's
/// problem, which queues rather than loses them.
final class CustomExerciseSaver: CustomExerciseUploading {

    private let local: CustomExerciseUploading
    private let remote: CustomExerciseUploading

    init(local: CustomExerciseUploading, remote: CustomExerciseUploading) {
        self.local = local
        self.remote = remote
    }

    func upload(_ exercise: CustomExercise) async throws {
        try await local.upload(exercise)

        Task.detached(priority: .background) { [remote] in
            try? await remote.upload(exercise)
        }
    }
}
