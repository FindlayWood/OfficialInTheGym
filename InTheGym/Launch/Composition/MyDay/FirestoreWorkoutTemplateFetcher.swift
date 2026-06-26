//
//  FirestoreWorkoutTemplateFetcher.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/06/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseFirestore
import MyDayKit

final class FirestoreWorkoutTemplateFetcher: WorkoutTemplateFetching {

    func fetchAll() async throws -> [WorkoutTemplateModel] {
        let db = Firestore.firestore()
        let userID = UserDefaults.currentUser.uid
        let snapshot = try await db
            .collection("Users/\(userID)/WorkoutTemplates")
            .getDocuments()

        return try snapshot.documents.compactMap { document in
            try document.data(as: WorkoutTemplateModel.self)
        }
    }
}
