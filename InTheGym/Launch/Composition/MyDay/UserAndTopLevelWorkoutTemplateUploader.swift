//
//  UserAndTopLevelWorkoutTemplateUploader.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Writes a template to the user's library, then to the top-level collection.
/// It knows no paths — each destination is its own writer, and this only
/// decides that both happen and in what order.
///
/// **The user copy goes first** because it is the one the library reads back;
/// the top-level copy is only reached once that has succeeded.
///
/// **Either failure throws**, so `WorkoutTemplateSyncer` queues the template
/// and `WorkoutTemplateSyncService` retries the whole composition. Both writes
/// are `setData`, which replaces, so a retry after the user copy already
/// landed rewrites it rather than duplicating it. This gives up the single
/// atomic batch — for a window the two copies can disagree — in exchange for
/// writers that each do one job; the retry is what closes the window.
final class UserAndTopLevelWorkoutTemplateUploader: WorkoutTemplateUploading {

    private let user: WorkoutTemplateUploading
    private let topLevel: WorkoutTemplateUploading

    init(user: WorkoutTemplateUploading, topLevel: WorkoutTemplateUploading) {
        self.user = user
        self.topLevel = topLevel
    }

    func upload(_ template: WorkoutTemplateModel) async throws {
        try await user.upload(template)
        try await topLevel.upload(template)
    }
}
