//
//  WorkoutTemplateModel+Settings.swift
//  MyDayKit
//
//  Created by Findlay Wood on 13/11/2026.
//

import Foundation

extension WorkoutTemplateModel {

    /// Whether `userId` may change this workout's visibility and tags on its page.
    ///
    /// **Only a workout they built themselves.** A copy saved from DISCOVER is filed under the
    /// saver (`copy(savedBy:)`), so `createdBy` alone would let them publish someone else's workout
    /// as their own — exactly what making copies private was for. `copiedFrom` is what tells the two
    /// apart.
    func isEditable(by userId: String) -> Bool {
        createdBy == userId && copiedFrom == nil
    }

    /// The same workout with new settings, stamped `updatedAt`. **The id, exercises and
    /// `createdAt` are unchanged**: the id is what the library, the sync queue and Firestore replace
    /// by, and `createdAt` is the library's sort key, so an edited workout stays where it was in the
    /// list. `updatedAt` is what makes this copy win `WorkoutLibraryManager.merge` against the old
    /// one. No tags is stored as `nil`, as a template that never had any is.
    func withSettings(isPublic: Bool, tags: [String], updatedAt: Date) -> WorkoutTemplateModel {
        WorkoutTemplateModel(
            id: id,
            title: title,
            description: description,
            exercises: exercises,
            createdBy: createdBy,
            isPublic: isPublic,
            tags: tags.isEmpty ? nil : tags,
            estimatedDuration: estimatedDuration,
            difficulty: difficulty,
            createdAt: createdAt,
            updatedAt: updatedAt,
            copiedFrom: copiedFrom
        )
    }
}
