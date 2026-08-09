//
//  WorkoutTemplateStoreLocation.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// The one definition of where locally saved workout templates live:
/// `Documents/WorkoutTemplates/{userId}/{templateId}.json`.
///
/// **Scoped by user id, because the device is shared.** The directory used to be
/// flat — every template from every account that had ever signed in on the phone
/// sat in `Documents/WorkoutTemplates`, and the library reads local first, so the
/// next user to sign in opened their library and saw the previous user's
/// workouts. `Documents/MyDays/{uid}/{date}.json` and
/// `Documents/PendingSync/workoutTemplates_{uid}.json` were already scoped this
/// way; this is the same shape.
///
/// Scoping rather than wiping on sign-out is deliberate: a template that has not
/// reached Firestore yet is still on disk when its owner signs back in.
///
/// The uploader, the fetcher and the legacy migrator all derive their path from
/// here. They used to work it out separately, which is exactly how the two sides
/// of a local store drift apart.
enum WorkoutTemplateStoreLocation {

    /// `Documents/WorkoutTemplates` — the parent of the per-user directories.
    /// Nothing writes JSON directly into it any more; see
    /// `LegacyWorkoutTemplateStoreMigrator` for what is still there.
    static var root: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("WorkoutTemplates", isDirectory: true)
    }

    /// `Documents/WorkoutTemplates/{userId}` — where that user's templates are
    /// read from and written to.
    static func directory(for userId: String) -> URL {
        root.appendingPathComponent(userId, isDirectory: true)
    }
}
