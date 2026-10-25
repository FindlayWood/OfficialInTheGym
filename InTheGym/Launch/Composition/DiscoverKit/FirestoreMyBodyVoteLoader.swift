//
//  FirestoreMyBodyVoteLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// The signed-in user's suggestion on an exercise. No document is no
/// suggestion.
struct FirestoreMyBodyVoteLoader: MyBodyVoteLoader {

    let userId: String

    func myBodyVote(onExercise exerciseId: String) async throws -> DiscoverBodyVote? {
        let path = DiscoverSubject.exercise(id: exerciseId).bodyVotePath(userId: userId)
        let snapshot = try await Firestore.firestore().document(path).getDocument()
        guard let groups = snapshot.get("muscleGroups") as? [String],
              let patterns = snapshot.get("movementPatterns") as? [String]
        else { return nil }
        return DiscoverBodyVote(muscleGroups: groups, movementPatterns: patterns)
    }
}
