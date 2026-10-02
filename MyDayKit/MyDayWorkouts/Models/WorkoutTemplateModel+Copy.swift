//
//  WorkoutTemplateModel+Copy.swift
//  MyDayKit
//
//  Created by Findlay Wood on 02/10/2026.
//

import Foundation

extension WorkoutTemplateModel {

    /// The template as saved into someone else's library — **a copy, never a
    /// reference.** A workout a user has started training from must not change
    /// under them because its author edited theirs; the same reason a
    /// coach-assigned workout is snapshotted at accept time.
    ///
    /// The copy is the saver's own: a new id, their `createdBy`, created now.
    /// It is **private** — it sits in their library, and a public copy would
    /// list someone else's workout in DISCOVER a second time under a new name.
    /// The exercises, sets and tags come across unchanged; `copiedFrom`
    /// records where it came from.
    public func copy(savedBy userId: String, id: String = UUID().uuidString, at date: Date = Date()) -> WorkoutTemplateModel {
        WorkoutTemplateModel(
            id: id,
            title: title,
            description: description,
            exercises: exercises,
            createdBy: userId,
            isPublic: false,
            tags: tags,
            estimatedDuration: estimatedDuration,
            difficulty: difficulty,
            createdAt: date,
            updatedAt: date,
            copiedFrom: self.id
        )
    }
}
