//
//  CustomExerciseUploading.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// Writes one custom exercise somewhere. The same protocol at every layer of
/// the pipeline, as `WorkoutTemplateUploading` is for templates: the local
/// file, each Firestore path, the sync queue and the decorators that compose
/// them all conform, so the composition root can wrap one in another.
///
/// **Creating, editing and archiving are all this one call.** A custom exercise
/// is written whole every time — an edit is the same exercise with a later
/// `updatedAt`, and an archive is one with `archivedAt` set — so there is no
/// separate update or delete for the two copies to disagree over.
public protocol CustomExerciseUploading {
    func upload(_ exercise: CustomExercise) async throws
}

/// Saves nothing, for SwiftUI previews of the form.
public struct PreviewCustomExerciseUploading: CustomExerciseUploading {
    public init() {}

    public func upload(_ exercise: CustomExercise) async throws {}
}
