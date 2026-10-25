//
//  ExerciseLibrary.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// The exercises the picker offers: the catalogue plus the user's own, and the
/// one rule for merging them.
///
/// **Catalogue first, by id.** Approving a custom exercise writes
/// `Exercises/{id}` under its own id, so once approved the catalogue and the
/// user's copy describe the same exercise. The catalogue's wins and the
/// "Yours" marker goes — the exercise is everyone's now — while the user's logs
/// and templates, which already point at that id, carry on unchanged. This is
/// why the picker keys rows by id.
///
/// **The two custom stores are unioned, newest `updatedAt` winning**, as
/// `WorkoutLibraryManager.merge` does for templates. Neither side is
/// authoritative: local holds what has not synced, remote holds what was made
/// on another device. On a tie the remote copy wins, because only it carries
/// the server's `status`.
///
/// **Archived exercises are left out.** Delete is an archive: the exercise
/// leaves the picker, but every log and template that names it keeps the id.
public struct ExerciseLibrary {

    /// Every exercise, catalogue and custom, as the picker lists them.
    public let exercises: [Exercise]
    /// The custom exercises among them, by id — what draws "Yours".
    public let customExercises: [String: CustomExercise]

    public init(catalogue: [Exercise], local: [CustomExercise], remote: [CustomExercise]) {
        let catalogueIds = Set(catalogue.map(\.id))

        var custom: [String: CustomExercise] = [:]
        for exercise in remote {
            custom[exercise.id] = exercise
        }
        for exercise in local {
            if let existing = custom[exercise.id], existing.updatedAt >= exercise.updatedAt {
                continue
            }
            custom[exercise.id] = exercise
        }

        let visible = custom.filter { id, exercise in
            exercise.archivedAt == nil && !catalogueIds.contains(id)
        }

        exercises = catalogue + visible.values.map(\.exercise)
        customExercises = visible
    }

    /// Whether `exercise` is one of the user's own.
    public func isCustom(_ exercise: Exercise) -> Bool {
        customExercises[exercise.id] != nil
    }
}
