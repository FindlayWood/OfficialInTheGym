//
//  FirestoreTopLevelWorkoutTemplateUploader.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseFirestore
import MyDayKit

/// Writes to `WorkoutTemplates/{id}` — every user's templates in one top-level
/// collection, so that finding templates across users does not mean reading
/// every user's library.
///
/// **This path only.** The author's own copy is `FirestoreWorkoutTemplateUploader`;
/// writing both is `UserAndTopLevelWorkoutTemplateUploader`'s job, not either
/// writer's. A writer that knows two destinations cannot be reused, replaced or
/// tested for one of them.
public final class FirestoreTopLevelWorkoutTemplateUploader: WorkoutTemplateUploading {

    public init() {}

    public func upload(_ template: WorkoutTemplateModel) async throws {
        let db = Firestore.firestore()
        let docRef = db
            .collection("WorkoutTemplates")
            .document(template.id)
        try await docRef.setData(from: template)
    }
}
