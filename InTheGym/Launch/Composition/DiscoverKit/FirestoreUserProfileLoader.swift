//
//  FirestoreUserProfileLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// Reads `Profiles/{uid}` for a set of ids, thirty at a time — the most one
/// Firestore `in` query accepts. Only `username` and `displayName` are read,
/// by hand, rather than decoding a whole model a comment row does not need.
///
/// **`Profiles`, never `Users`.** This used to query other people's
/// `Users/{uid}` documents, and Firestore rules cannot hide single fields, so
/// whatever let it through let any signed-in user read anyone's email.
/// `Profiles/{uid}` is the public projection the `syncProfile` Cloud Function
/// writes, holding only what others may see (`PROFILE_PLAN.md` step 2), and the
/// rules close `Users/{uid}` to its owner once every reader has moved here.
struct FirestoreUserProfileLoader: UserProfileLoader {

    static let batchSize = 30

    func profiles(for userIds: Set<String>) async throws -> [String: DiscoverUserProfile] {
        let ids = Array(userIds)
        let batches = stride(from: 0, to: ids.count, by: Self.batchSize).map {
            Array(ids[$0..<min($0 + Self.batchSize, ids.count)])
        }
        let profiles = Firestore.firestore().collection("Profiles")

        return try await withThrowingTaskGroup(of: [DiscoverUserProfile].self) { group in
            for batch in batches {
                group.addTask {
                    let snapshot = try await profiles.whereField(FieldPath.documentID(), in: batch).getDocuments()
                    return snapshot.documents.map { document in
                        DiscoverUserProfile(
                            userId: document.documentID,
                            username: document.get("username") as? String ?? "",
                            displayName: document.get("displayName") as? String ?? ""
                        )
                    }
                }
            }
            var profiles: [String: DiscoverUserProfile] = [:]
            for try await batch in group {
                for profile in batch { profiles[profile.userId] = profile }
            }
            return profiles
        }
    }
}
