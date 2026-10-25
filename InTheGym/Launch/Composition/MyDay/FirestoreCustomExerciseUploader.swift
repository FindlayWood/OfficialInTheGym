//
//  FirestoreCustomExerciseUploader.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import MyDayKit

/// Writes `Users/{createdBy}/CustomExercises/{id}` — the creator's copy, which
/// their picker reads. This path only; the review copy is
/// `FirestoreTopLevelCustomExerciseUploader`, and
/// `UserAndTopLevelCustomExerciseUploader` composes the two.
///
/// **A merge, never a replace.** `CustomExercise` does not encode `status`,
/// which a Cloud Function mirrors onto this document from the review copy. A
/// plain `setData` would delete it on every edit, and the creator would see
/// "In review" vanish.
final class FirestoreCustomExerciseUploader: CustomExerciseUploading {

    func upload(_ exercise: CustomExercise) async throws {
        try await Firestore.firestore()
            .collection("Users/\(exercise.createdBy)/CustomExercises")
            .document(exercise.id)
            .setData(from: exercise, merge: true)
    }
}
