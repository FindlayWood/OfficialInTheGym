//
//  FirestoreWorkoutTemplateByIdFetcher.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation
import MyDayKit

/// Reads the top-level `WorkoutTemplates/{id}` — every public template is
/// there, whoever wrote it — decoded as MyDayKit's own model, so the template's
/// shape keeps the one owner.
struct FirestoreWorkoutTemplateByIdFetcher: WorkoutTemplateByIdFetching {

    func fetch(templateId: String) async throws -> WorkoutTemplateModel {
        try await Firestore.firestore()
            .document(DiscoverSubject.workout(id: templateId).documentPath)
            .getDocument(as: WorkoutTemplateModel.self)
    }
}
