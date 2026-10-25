//
//  FirestoreBodyVoteWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// Writes the signed-in user's whole suggestion on an exercise, replacing the
/// last. `discoverExerciseBodyVotes` tallies it for review; it never changes
/// the exercise.
struct FirestoreBodyVoteWriter: BodyVoteWriter {

    let userId: String

    func setMyBodyVote(_ vote: DiscoverBodyVote, onExercise exerciseId: String) async throws {
        let path = DiscoverSubject.exercise(id: exerciseId).bodyVotePath(userId: userId)
        try await Firestore.firestore().document(path).setData([
            "muscleGroups": vote.muscleGroups,
            "movementPatterns": vote.movementPatterns,
            "authorId": userId,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
}
