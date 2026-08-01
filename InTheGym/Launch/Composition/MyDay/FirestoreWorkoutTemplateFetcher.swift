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

        // Decode per document. A template written before `exerciseName` /
        // `exerciseCategory` were added to WorkoutExerciseModel cannot decode,
        // and must not be allowed to take the rest of the library with it.
        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: WorkoutTemplateModel.self)
            } catch {
                print("❌ Skipping workout template \(document.documentID): \(error)")
                return nil
            }
        }
    }
}
