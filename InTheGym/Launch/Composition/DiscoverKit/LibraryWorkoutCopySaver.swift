//
//  LibraryWorkoutCopySaver.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import Foundation
import MyDayKit

/// Saves a copy of a public workout into the signed-in user's library: read the
/// original, copy it (`WorkoutTemplateModel.copy(savedBy:)` — the one
/// definition of what a copy is), write it through MyDay's own saver, then add
/// it to MyDay's library manager.
///
/// Knows no paths: the reader and the saver each own theirs, and the saver is
/// MyDay's `WorkoutTemplateSaver`, so the copy is written locally first and
/// reaches Firestore through the same sync queue as a template built in MyDay.
struct LibraryWorkoutCopySaver: WorkoutCopySaver {

    let fetcher: WorkoutTemplateByIdFetching
    let library: MyDayWorkoutLibrary
    let userId: String

    func saveCopy(ofWorkout templateId: String) async throws {
        let original = try await fetcher.fetch(templateId: templateId)
        let copy = original.copy(savedBy: userId)
        try await library.saver.upload(copy)
        await MainActor.run {
            library.manager.addTemplate(copy)
        }
    }
}
