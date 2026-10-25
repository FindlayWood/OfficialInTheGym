//
//  FirestoreTopLevelCustomExerciseUploader.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import MyDayKit

/// Writes `CustomExercises/{id}` — every user's custom exercises in one
/// collection, which is what the dashboards review. This path only; see
/// `UserAndTopLevelCustomExerciseUploader`.
///
/// **Never `Exercises/{id}`.** A write there fires `discoverExerciseCard` and
/// publishes a DISCOVER card. Only approval writes the catalogue, and only from
/// a dashboard.
///
/// **A merge, and no `status`.** The dashboards own `status` here, and the
/// server sets `pending` when the document is created. The app writing it
/// would let a late edit or archive put a reviewed exercise back in the queue.
final class FirestoreTopLevelCustomExerciseUploader: CustomExerciseUploading {

    func upload(_ exercise: CustomExercise) async throws {
        try await Firestore.firestore()
            .collection("CustomExercises")
            .document(exercise.id)
            .setData(from: exercise, merge: true)
    }
}
